//
//  FFHBitrateCalc.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/05/16.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHBitrateCalc.h"

typedef enum : NSUInteger {
    FFHCalcTypeBitrate,
    FFHCalcTypeSize,
    FFHCalcTypeTime,
} FFHCalcType;

@interface FFHBitrateCalc () {
    IBOutlet NSTextField *_mibTextField;
    IBOutlet NSTextField *_lenTextField;
    IBOutlet NSTextField *_bitrateTextField;
    
    IBOutlet NSTextField *_audioBitrateTextField;
    IBOutlet NSTextField *_videoBitrateTextField;
    
    IBOutlet NSSegmentedControl *_segmentedControl;
}

@end

@implementation FFHBitrateCalc

- (NSString *)windowNibName {
    return self.className;
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];
    _lenTextField.floatValue = [_delegate mediaLengthForBitrateCalc:self];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    NSPanel *panel = (id)self.window;
    panel.floatingPanel = NO;
}

- (IBAction)textFieldAction:(NSTextField *)sender {
    FFHCalcType segment = _segmentedControl.selectedSegment;
    float size = _mibTextField.floatValue,
          len = _lenTextField.floatValue,
          bitrate = _bitrateTextField.floatValue;
    switch (segment) {
        case FFHCalcTypeBitrate:
        {
            float r = size * 8192 / len;
            _bitrateTextField.floatValue = r;
            _videoBitrateTextField.floatValue = r - _audioBitrateTextField.floatValue;
        }
            break;
        case FFHCalcTypeTime:
            _lenTextField.floatValue = 1/(bitrate/(size * 8192));
            break;
        case FFHCalcTypeSize:
            _mibTextField.floatValue = bitrate * len / 8192;
            break;
            
        default:
            break;
    }
}

- (IBAction)updateButtonAction:(id)sender {
    _lenTextField.floatValue = [_delegate mediaLengthForBitrateCalc:self];
}

- (IBAction)OKButtonAction:(id)sender {
    [self.window performClose:sender];
}
@end
