//
//  FFHClipList.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/03/15.
//  Copyright © 2018年 Terminator. All rights reserved.
//

@import Cocoa;
@class FFHClipItem;
@protocol FFHClipListDelegate;

@interface FFHClipList : NSObject

- (void)addClipItem:(FFHClipItem *)item;
- (void)removeClipItem:(FFHClipItem *)item;
@property id<FFHClipListDelegate> delegate;
@property (readonly) NSMenu *menu;
@property NSString *toolTip;

@end

@protocol FFHClipListDelegate <NSObject>

- (FFHClipItem *)addNewClipToList:(FFHClipList *)list;
- (void)clipList:(FFHClipList *)list itemClicked:(FFHClipItem *)item;

@end