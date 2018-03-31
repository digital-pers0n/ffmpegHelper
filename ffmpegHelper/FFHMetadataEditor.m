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
                        _cachedMetadata.title, _cachedMetadata.artist,
                        _cachedMetadata.date, _cachedMetadata.comment];
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
