//
//  FFHSegmentList.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/03/12.
//  Copyright © 2018年 Terminator. All rights reserved.
//

@import Cocoa;
@class FFHSegmentItem;
@protocol FFHSegmentListDelegate;

@interface FFHSegmentList : NSObject

- (void)addSegmentItem:(FFHSegmentItem *)item;
- (void)removeSegmentItem:(FFHSegmentItem *)item;
@property id<FFHSegmentListDelegate> delegate;
@property (readonly) NSMenu *menu;

@end

@protocol FFHSegmentListDelegate <NSObject>

- (FFHSegmentItem *)addNewItemToList:(FFHSegmentList *)list;
- (void)segmentList:(FFHSegmentList *)list itemClicked:(FFHSegmentItem *)item;

@end