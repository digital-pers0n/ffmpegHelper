//
//  FFHFileInfo.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/01/11.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHFileInfo.h"

void _findStreams(NSString *str, NSMutableArray *streams);

@interface FFHFileInfo () {
    IBOutlet NSTextField *_fileInfoTextField;
    NSString *_fileInfoString;
    NSString *_filePath;
    NSMutableArray *_streams;
    NSData *_data;
}

@end

@implementation FFHFileInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = @"";
        _streams = [NSMutableArray new];
        _bitrate = @"";
    }
    return self;
}

- (NSString *)windowNibName {
    return self.className;
}

- (void)setData:(NSData *)data {
    _data = data;
    NSString *rawInfo = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    if (!rawInfo) {
        rawInfo = [[NSString alloc] initWithData:_data encoding:[NSString defaultCStringEncoding]];
        if (!rawInfo) {
            NSLog(@"%s Error: cannot convert data to string", __PRETTY_FUNCTION__);
            return;
        }
    }
    NSRange r1 , r2 = {0, rawInfo.length};
    r1 = [rawInfo rangeOfString:@"Duration: " options:NSLiteralSearch range:r2];
    if (r1.length) {
        _fileInfoString = [rawInfo substringWithRange:(NSRange){r1.location, r2.length - r1.location}];
        r2 = [_fileInfoString rangeOfString:@","];
        _duration = [_fileInfoString substringWithRange:(NSRange){r1.length, r2.location - r1.length}];
        
        r1 = [_fileInfoString rangeOfString:@"bitrate: "];
        r2 = [_fileInfoString rangeOfString:@"\n"];
        _bitrate = [_fileInfoString substringWithRange:(NSRange){r1.length + r1.location, r2.location - r1.location - r1.length}];
        
        [_streams removeAllObjects];
        _findStreams(_fileInfoString, _streams);
        _numberOfStreams = _streams.count;
    } else {
        _fileInfoString = rawInfo;
        _duration = @"";
        _bitrate = @"";
        _numberOfStreams = 0;
        [_streams removeAllObjects];
    }
}

- (NSData *)data {
    return _data;
}

- (void)setFilePath:(NSString *)filePath {
    _filePath = filePath;
    NSTask *task = [[NSTask alloc] init];
    NSPipe *outPipe = [[NSPipe alloc] init];
    task.launchPath = @"/usr/local/bin/ffprobe";
    task.arguments = @[@"-hide_banner", @"-i", filePath];
    task.standardError = outPipe;
    [task launch];
    
    self.data = [[task.standardError fileHandleForReading] readDataToEndOfFile];
   
}
- (NSString *)filePath {
    return _filePath;
}

- (void)showFileInfo {
    [self.window makeKeyAndOrderFront:nil];
    if (_fileInfoString) {
        _fileInfoTextField.stringValue = _fileInfoString;
    }
}

- (void)showFileInfo:(NSString *)filePath {
    self.filePath = filePath;
    [self showFileInfo];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSPanel *panel = (id)self.window;
    panel.floatingPanel = NO;
}

@end

void _findStreams(NSString *str, NSMutableArray *streams) {
    NSString *stream;
    NSRange r1 = [str rangeOfString:@"Stream #" options:NSLiteralSearch];
    if (r1.length) {
        stream = [str substringWithRange:(NSRange){r1.location, str.length - r1.location}];
        r1.location = 0;
        NSRange r2 = [stream rangeOfString:@"\n"];
        NSRange r3 = {r1.location, r2.location};
        [streams addObject:[stream substringWithRange:r3]];
        stream = [stream substringWithRange:(NSRange){r3.length, stream.length - r3.length}];
        _findStreams(stream, streams);
    } else {
        return;
    }
}
