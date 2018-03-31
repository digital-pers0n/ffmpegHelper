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
    _filepath = filePath;
}

- (NSString *)filepath {
    return _filepath;
}

-(void)_updateViews {
    [_cachedMetadata enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
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
