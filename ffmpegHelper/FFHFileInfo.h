//
//  FFHFileInfo.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/01/11.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FFHFileInfo : NSWindowController

@property NSData *data; // ffprobe output
@property NSString *filePath;
@property (readonly) NSString *fileInfoString;
@property (readonly) NSString *duration;
@property (readonly) NSString *bitrate;
@property (readonly) NSUInteger numberOfStreams;
@property (readonly) NSArray *streams;

- (void)showFileInfo;
- (void)showFileInfo:(NSString *)filePath;

@end
