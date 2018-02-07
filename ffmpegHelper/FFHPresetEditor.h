//
//  FFHPresetEditor.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/02/06.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FFHPresetEditor : NSWindowController

@property NSString *presetsFilePath;
- (void)showPresetsEditor;

@end
