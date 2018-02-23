//
//  FFHPresetItem.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/02/21.
//  Copyright © 2018年 Terminator. All rights reserved.
//

@import Cocoa;

// dictionary keys
extern NSString *FFHPresetNameKey;
extern NSString *FFHVideoOptionsKey;
extern NSString *FFHMiscOptionsKey;
extern NSString *FFHOtherOptionsKey;
extern NSString *FFHAudioOptionsKey;
extern NSString *FFHContainerKey;

@interface FFHPresetItem : NSObject <NSCopying, NSPasteboardWriting/*, NSPasteboardReading*/>

@property NSString *name;
@property NSString *videoOptions;
@property NSString *miscOptions;
@property NSString *otherOptions;
@property NSString *audioOptions;
@property NSString *container;

@property NSDictionary *dictionary;

@end
