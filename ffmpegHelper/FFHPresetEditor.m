//
//  FFHPresetEditor.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/02/06.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHPresetEditor.h"

@interface FFHPresetEditor () {
    IBOutlet NSTableView *_tableView;
    IBOutlet NSTextField *_nameTextField;
    IBOutlet NSTextField *_containerTextField;
    IBOutlet NSTextField *_videoTextField;
    IBOutlet NSTextField *_otherTextField;
    IBOutlet NSTextField *_audioTextField;
    IBOutlet NSTextField *_miscTextField;
    
    IBOutlet NSPanel *_presetsPanel;
}
- (IBAction)tableViewDoubleClickAction:(id)sender;
- (IBAction)editButtonClicked:(id)sender;
- (IBAction)addPresetButtonClicked:(id)sender;
- (IBAction)removePresetButtonClicked:(id)sender;

- (IBAction)presetEditorOKButtonClicked:(id)sender;
- (IBAction)presetEditorCancelButtonClicked:(id)sender;
@end

@implementation FFHPresetEditor

- (NSString *)windowNibName {
    return self.className;
}

- (void)windowDidLoad {
    [super windowDidLoad];

}

- (void)showPresetsEditor {
    if (![self isWindowLoaded]) {
        
    }
    [_presetsPanel makeKeyAndOrderFront:nil];
    [_tableView reloadData];
}

#pragma mark - IBAction methods

- (IBAction)tableViewDoubleClickAction:(id)sender {
}

- (IBAction)editButtonClicked:(id)sender {
}

- (IBAction)addPresetButtonClicked:(id)sender {
}

- (IBAction)removePresetButtonClicked:(id)sender {
}

- (IBAction)presetEditorOKButtonClicked:(id)sender {
}

- (IBAction)presetEditorCancelButtonClicked:(id)sender {
}
@end
