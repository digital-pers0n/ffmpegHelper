//
//  FFHMetadataEditor.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/01/18.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol FFHMetadataEditorDelegate;

@interface FFHMetadataEditor : NSWindowController

@property id<FFHMetadataEditorDelegate> delegate;

@property NSData *data;
@property NSString *filepath;
@property (readonly) NSString *metadata;

@end

@protocol FFHMetadataEditorDelegate <NSObject>

-(void)metadataDidChange;

@end