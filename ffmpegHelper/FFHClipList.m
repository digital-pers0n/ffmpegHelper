//
//  FFHClipList.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/03/15.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHClipList.h"
#import "FFHClipItem.h"

@interface FFHClipList () {
    NSArray *_defaultMenuItems;
}

@end

@implementation FFHClipList

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSMenuItem *item;
        _menu = [[NSMenu alloc] init];
        _menu.title = @"Clips";
        item = [[NSMenuItem alloc] initWithTitle:@"Add Clip" action:@selector(addClip:) keyEquivalent:@""];
        item.target = self;
        [_menu addItem:item];
        
        item = [[NSMenuItem alloc] initWithTitle:@"Remove All" action:@selector(removeAllClips:) keyEquivalent:@""];
        item.target = self;
        [_menu addItem:item];
        [_menu addItem:[NSMenuItem separatorItem]];
        _defaultMenuItems = [[_menu itemArray] copy];
    }
    return self;
}

- (void)addClipItem:(FFHClipItem *)clip {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:clip.outputFilePath.lastPathComponent.stringByDeletingPathExtension
                                                  action:@selector(defaultItemAction:)
                                           keyEquivalent:@""];
    item.target = self;
    item.representedObject = clip;
    item.toolTip = _toolTip;
    [_menu addItem:item];
}

- (void)removeClipItem:(FFHClipItem *)item {
    NSMenuItem *itm = [_menu itemAtIndex:[_menu indexOfItemWithRepresentedObject:item]];
    if (item) {
        [_menu removeItem:itm];
    }
}

#pragma mark - Menu Item Actions

- (void)defaultItemAction:(NSMenuItem *)sender {
    FFHClipItem *item = sender.representedObject;
    [_delegate clipList:self itemClicked:item];
}

- (void)addClip:(id)sender {
    FFHClipItem *item = [_delegate addNewClipToList:self];
    if (item) {
        [self addClipItem:item];
    }
}

- (void)removeAllClips:(id)sender {
    [_menu removeAllItems];
    for (NSMenuItem *itm in _defaultMenuItems) {
        [_menu addItem:itm];
    }
}

@end
