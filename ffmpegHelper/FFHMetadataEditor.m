//
//  FFHMetadataEditor.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/01/18.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHMetadataEditor.h"

@interface FFHMetadataItem : NSObject
@property NSString *artist;
@property NSString *date;
@property NSString *title;
@property NSString *comment;
@end

@implementation FFHMetadataItem
@end

typedef NS_ENUM(NSUInteger, FFHMetadata) {
    FFHMetadataTitle = 0,
    FFHMetadataArtist,
    FFHMetadataDate,
    FFHMetadataComment,
};

NSString * const FFHMetadataTitleString = @"title           : ";
NSString * const FFHMetadataArtistString =  @"artist          : ";
NSString * const FFHMetadataDateString =  @"date            : ";
NSString * const FFHMetadataCommentString = @"comment         : ";

@interface FFHMetadataEditor () {
    IBOutlet NSTextField *_titleTextField;
    IBOutlet NSTextField *_artistTextField;
    IBOutlet NSTextField *_dateTextField;
    IBOutlet NSTextField *_commentTextField;
    
    NSString *_filepath;
    FFHMetadataItem *_cachedMetadata;
    NSString *_metadataString;
    NSData *_data;
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
        _cachedMetadata = [FFHMetadataItem new];
    }
    return self;
}

static inline NSString *_getMetadata(NSString *metadata, NSUInteger *length, NSString *field, NSString *empty) {
    NSRange r1, r2;
    NSString *result;
    r1 = [metadata rangeOfString:field];
    if (r1.length) {
        r2 = [metadata rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:(NSRange){r1.location, *length - r1.location}];
        NSUInteger start = r1.location + r1.length;
        result = [metadata substringWithRange:(NSRange){start, r2.location - start}];
    } else {
        result = empty;
    }
    return result;
}

- (void)setData:(NSData *)outData {
    NSString *rawInfo = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
    if (!rawInfo) {
        NSLog(@"%s Error: cannot convert data to string", __PRETTY_FUNCTION__);
        _cachedMetadata.title = _filepath.lastPathComponent.stringByDeletingPathExtension;;
        return;
    }
    NSRange r1, r2 = {0, rawInfo.length}, r3;
    r1 = [rawInfo rangeOfString:@"Metadata:" options:NSLiteralSearch range:r2];
    if (r1.length) {
        r3 = [rawInfo rangeOfString:@"Duration: " options:NSLiteralSearch range:r2];
        if (r3.length) {
            _metadataString = [rawInfo substringWithRange:(NSRange){r1.location + r1.length + 1, r3.location - r1.length - r1.location - 1}];
            NSUInteger length = _metadataString.length;
            NSString *empty = @"";
            
            NSString *title = _getMetadata(_metadataString, &length, FFHMetadataTitleString, empty);
            if (title.length == 0) {
                title = _filepath.lastPathComponent.stringByDeletingPathExtension;
            }
            _cachedMetadata.title = title;
            _cachedMetadata.artist = _getMetadata(_metadataString, &length, FFHMetadataArtistString, empty);
            _cachedMetadata.date = _getMetadata(_metadataString, &length, FFHMetadataDateString, empty);
            _cachedMetadata.comment = _getMetadata(_metadataString, &length, FFHMetadataCommentString, empty);
            if ([self isWindowLoaded]) {
                [self _updateViews];
            }
        }
    }
    
}

- (NSData *)data {
    return _data;
}

- (void)setFilepath:(NSString *)filePath {
    _filepath = filePath;
}

- (NSString *)filepath {
    return _filepath;
}

-(void)_updateViews {
    _artistTextField.stringValue = _cachedMetadata.artist;
    _titleTextField.stringValue = _cachedMetadata.title;
    _dateTextField.stringValue = _cachedMetadata.date;
    _commentTextField.stringValue = _cachedMetadata.comment;
}

- (NSString *)metadata  {
    NSString *result = [NSString stringWithFormat:
                        @"-metadata title=\"%@\" "
                        @"-metadata artist=\"%@\" "
                        @"-metadata date=\"%@\" "
                        @"-metadata comment=\"%@\"",
                        [_cachedMetadata.title stringByReplacingOccurrencesOfString:@"\"" withString:@"'"],
                        _cachedMetadata.artist,
                        _cachedMetadata.date,
                        [_cachedMetadata.comment stringByReplacingOccurrencesOfString:@"\"" withString:@"'"]
                        ];
    return result;
}

- (void)_updateCachedMetadata {
    _cachedMetadata.artist = _artistTextField.stringValue;
    _cachedMetadata.title = _titleTextField.stringValue;
    _cachedMetadata.date = _dateTextField.stringValue;
    _cachedMetadata.comment = _commentTextField.stringValue;
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
