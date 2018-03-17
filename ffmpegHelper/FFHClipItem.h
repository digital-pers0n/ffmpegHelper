//
//  FFHClipItem.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/03/15.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FFHCommandData;

@interface FFHClipItem : NSObject

@property (copy) FFHCommandData *commandData;
@property (copy) NSString *inputFilePath;
@property (copy) NSString *outputFilePath;
@property (copy) NSString *metadataString;

@end
