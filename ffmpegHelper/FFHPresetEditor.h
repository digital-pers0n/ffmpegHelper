//
//  FFHPresetEditor.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/02/06.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//Notifications
extern NSString *FFHPresetEditorDidChangeDataNotification;

@interface FFHPresetEditor : NSWindowController

@property NSString *presetsFilePath;
- (void)showPresetsListPanel;
@property NSArray *userPresets;

- (void)savePresets;

@end