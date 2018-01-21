//
//  FFHMetadataEditor.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/01/18.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol FFHMetadaEditorDelegate;

@interface FFHMetadataEditor : NSWindowController

@property id<FFHMetadaEditorDelegate> delegate;

@property NSString *filepath;
@property (readonly) NSString *metadata;

@end

@protocol FFHMetadaEditorDelegate <NSObject>

-(void)metadataDidChange;

@end