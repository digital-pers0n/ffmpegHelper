//
//  FFHMetadataEditor.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/01/18.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHMetadataEditor.h"

typedef NS_ENUM(NSUInteger, FFHMetadata) {
    FFHMetadataTitle = 0,
    FFHMetadataArtist,
    FFHMetadataDate,
    FFHMetadataComment,
};

@interface FFHMetadataEditor () {
    IBOutlet NSTextField *_titleTextField;
    IBOutlet NSTextField *_artistTextField;
    IBOutlet NSTextField *_dateTextField;
    IBOutlet NSTextField *_commentTextField;
    
    NSString *_filepath;
    NSArray *_metadataFields;
    NSMutableDictionary *_cachedMetadata;
    
}
- (IBAction)titleTextFieldChanged:(NSTextField *)sender;
- (IBAction)artistTextFieldChanged:(NSTextField *)sender;
- (IBAction)dateTextFieldChanged:(NSTextField *)sender;
- (IBAction)commentTextFieldChanged:(NSTextField *)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)okButtonClicked:(id)sender;
- (IBAction)applyButtonClicked:(id)sender;

@end

@implementation FFHMetadataEditor

- (NSString *)windowNibName {
    return self.className;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSPanel *panel = (id)self.window;
    panel.floatingPanel = NO;
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];
    [self _updateViews];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cachedMetadata = [NSMutableDictionary new];
        _metadataFields = @[@"title           :", @"artist          :", @"date            :", @"comment         :"];
        for (NSString *s in _metadataFields) {
            _cachedMetadata[s] = @"";
        }
    }
    return self;
}

- (void)setFilepath:(NSString *)filePath {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *outPipe = [[NSPipe alloc] init];
    task.launchPath = @"/usr/local/bin/ffprobe";
    task.arguments = @[@"-hide_banner", @"-i", filePath];
    task.standardError = outPipe;
    [task launch];
    
    NSData *outData = [[task.standardError fileHandleForReading] readDataToEndOfFile];
    NSArray *outArray = [[[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"];
    __block NSUInteger hits = 0;
    NSUInteger count = _metadataFields.count;
    NSMutableIndexSet *indices = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)];
    __block NSRange range;
    for (NSString *s in outArray) {
        [_metadataFields enumerateObjectsAtIndexes:indices.copy options:0 usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            range = [s rangeOfString:obj];
            if (range.length) {
                NSString *subs = [s substringFromIndex:range.length + range.location + 1];
                _cachedMetadata[obj] = [subs stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
//                _cachedMetadata[obj] = [subs stringByReplacingOccurrencesOfString:@"'" withString:@"\\\""];
//                _cachedMetadata[obj] = subs;
                *stop = YES;
                hits++;
                [indices removeIndex:idx];
            }
        }];
        if (hits == count) {
            break;
        }
    }
    if (indices.count) {
        [_metadataFields enumerateObjectsAtIndexes:indices options:0 usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == FFHMetadataTitle) {
                NSString *title = filePath.lastPathComponent.stringByDeletingPathExtension;
                if (title) {
                    _titleTextField.stringValue = title;
                    _cachedMetadata[_metadataFields[FFHMetadataTitle]] = title;
                }
            } else {
               _cachedMetadata[_metadataFields[idx]] = @"";
            }
        }];
    }
    if ([self isWindowLoaded]) {
        [self _updateViews];
    }
}

- (NSString *)filepath {
    return _filepath;
}

-(void)_updateViews {
    [_cachedMetadata enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:_metadataFields[FFHMetadataArtist]]) {
            _artistTextField.stringValue = obj;
        } else if ([key isEqualToString:_metadataFields[FFHMetadataTitle]]) {
            _titleTextField.stringValue = obj;
        } else if ([key isEqualToString:_metadataFields[FFHMetadataDate]]) {
            _dateTextField.stringValue = obj;
        } else if ([key isEqualToString:_metadataFields[FFHMetadataComment]]) {
            _commentTextField.stringValue = obj;
        }
    }];
}

- (NSString *)metadata  {
//    NSString *result = [NSString stringWithFormat:@"MARTIST=\"%@\"\n"
//                        @"MTITLE=\"%@\"\n"
//                        @"MDATE=\"%@\"\n"
//                        @"MCOMMENT=\"%@\"\n"
//                        @"MDATA=\"-metadata title=\\\"$MTITLE\\\" "
//                        @"-metadata artist=\\\"$MARTIST\\\" "
//                        @"-metadata date=\\\"$MDATE\\\" "
//                        @"-metadata comment=\\\"MCOMMENT\\\"\"\n",
//                        _cachedMetadata[_metadataFields[FFHMetadataArtist]], _cachedMetadata[_metadataFields[FFHMetadataTitle]],
//                        _cachedMetadata[_metadataFields[FFHMetadataDate]], _cachedMetadata[_metadataFields[FFHMetadataComment]]];
    NSString *result = [NSString stringWithFormat:
                        @"-metadata title=\"%@\" "
                        @"-metadata artist=\"%@\" "
                        @"-metadata date=\"%@\" "
                        @"-metadata comment=\"%@\"",
                        _cachedMetadata[_metadataFields[FFHMetadataTitle]],_cachedMetadata[_metadataFields[FFHMetadataArtist]],
                        _cachedMetadata[_metadataFields[FFHMetadataDate]], _cachedMetadata[_metadataFields[FFHMetadataComment]]];
    return result;
}

- (void)_updateCachedMetadata {
    _cachedMetadata[_metadataFields[FFHMetadataArtist]] = _artistTextField.stringValue;
    _cachedMetadata[_metadataFields[FFHMetadataTitle]] = _titleTextField.stringValue;
    _cachedMetadata[_metadataFields[FFHMetadataDate]] = _dateTextField.stringValue;
    _cachedMetadata[_metadataFields[FFHMetadataComment]] = _commentTextField.stringValue;
    [_delegate metadataDidChange];
}

#pragma mark IBActions

- (IBAction)titleTextFieldChanged:(NSTextField *)sender {
}

- (IBAction)artistTextFieldChanged:(NSTextField *)sender {
}

- (IBAction)dateTextFieldChanged:(NSTextField *)sender {
}

- (IBAction)commentTextFieldChanged:(NSTextField *)sender {
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self.window close];
}

- (IBAction)okButtonClicked:(id)sender {
    [self _updateCachedMetadata];
    [self.window close];
}

- (IBAction)applyButtonClicked:(id)sender {
    [self _updateCachedMetadata];
}
@end
