//
//  FFHFileInfo.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/01/11.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHFileInfo.h"

@interface FFHFileInfo () {
    IBOutlet NSTextField *_fileInfoTextField;
    NSString *_fileInfoString;
}

@end

@implementation FFHFileInfo

- (NSString *)windowNibName {
    return self.className;
}

- (void)showFileInfo:(NSString *)filePath {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *outPipe = [[NSPipe alloc] init];
    task.launchPath = @"/usr/local/bin/ffprobe";
    task.arguments = @[filePath];
    task.standardError = outPipe;
    [task launch];
    
    NSData *outData = [[task.standardError fileHandleForReading] readDataToEndOfFile];
    NSArray *outArray = [[[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"];
    NSMutableArray *infoArray = [NSMutableArray new];
    NSRange range;
    NSString *input = @"Input #";
    for (NSString *s in outArray) {
        range = [s rangeOfString:input];
        if (range.length) {
            NSUInteger idx = [outArray indexOfObject:s], count = outArray.count, i;
            
            for (i = idx; i < count - 1; i++) {
                input = outArray[i];
                [infoArray addObject:input];
            }
            break;
        }
    }
    
    _fileInfoString = [infoArray componentsJoinedByString:@"\n"];
    if (self.windowLoaded && _fileInfoString) {
        _fileInfoTextField.stringValue = _fileInfoString;
    }

}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSPanel *panel = (id)self.window;
    panel.floatingPanel = NO;
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
