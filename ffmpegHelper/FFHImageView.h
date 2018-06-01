//
//  FFHImageView.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/05/10.
//  Copyright © 2018年 Terminator. All rights reserved.
//

@import Quartz;

@protocol FFHImageViewDelegate;

@interface IKImageView (Private)

/* ImageKit class-dump */
- (NSRect)selectionRect;
- (void)setSelectionRect:(NSRect)rect;
- (IBAction)showInspector:(id)sender;
- (IBAction)closeInspector:(id)sender;

@end

@interface FFHImageView : IKImageView

@property (assign) id <FFHImageViewDelegate> delegate;

@end

@protocol FFHImageViewDelegate <NSObject>

- (void)imageViewSelectionDidChange:(FFHImageView *)imageView;

@end