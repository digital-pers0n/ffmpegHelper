//
//  FFHSegmentList.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/03/12.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHSegmentList.h"
#import "FFHSegmentItem.h"

@interface FFHSegmentList () {
    NSArray *_defaultMenuItems;
    NSUInteger _numberOfSegmentItems;
}

@end

@implementation FFHSegmentList

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMenuItem *item;
        _menu = [[NSMenu alloc] init];
        _menu.title = @"Segments";
        item = [[NSMenuItem alloc] initWithTitle:@"Add Segment" action:@selector(addSegment:) keyEquivalent:@""];
        item.target = self;
        [_menu addItem:item];
        
        item = [[NSMenuItem alloc] initWithTitle:@"Remove All" action:@selector(removeAllSegments:) keyEquivalent:@""];
        item.target = self;
        [_menu addItem:item];
        [_menu addItem:[NSMenuItem separatorItem]];
        _defaultMenuItems = [[_menu itemArray] copy];
        _numberOfSegmentItems = 0;
    }
    return self;
}

- (void)addSegmentItem:(FFHSegmentItem *)si {
    _numberOfSegmentItems++;
    NSString *title = [NSString stringWithFormat:@"%lu: %.3f - %.3f",
                       _numberOfSegmentItems,
                       si.startTime,
                       si.endTime];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(defaultItemAction:) keyEquivalent:@""];
    item.target = self;
    item.representedObject = si;
    item.toolTip = _toolTip;
    [_menu addItem:item];
}

- (void)removeSegmentItem:(FFHSegmentItem *)item {
    NSMenuItem *itm = [_menu itemAtIndex:[_menu indexOfItemWithRepresentedObject:item]];
    if (item) {
        [_menu removeItem:itm];
        _numberOfSegmentItems--;
    }
}

#pragma mark - Menu Item Actions

- (void)defaultItemAction:(NSMenuItem *)sender {
    FFHSegmentItem *item = sender.representedObject;
    [_delegate segmentList:self itemClicked:item];
}

- (void)addSegment:(id)sender {
    FFHSegmentItem *item = [_delegate addNewItemToList:self];
    if (item) {
        [self addSegmentItem:item];
    }
}

- (void)removeAllSegments:(id)sender {
    [_menu removeAllItems];
    for (NSMenuItem *itm in _defaultMenuItems) {
        [_menu addItem:itm];
    }
    _numberOfSegmentItems = 0;
}

@end
