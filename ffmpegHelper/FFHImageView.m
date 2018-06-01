//
//  FFHImageView.m
//  ffmpegHelper
//
//  Created by Terminator on 2018/05/10.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import "FFHImageView.h"

@interface FFHImageView ()

@property BOOL zoomed;
@property BOOL hasInspector;

@end

@implementation FFHImageView

@synthesize delegate = _delegate;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBActions

- (IBAction)showInspector:(id)sender {
    if (_hasInspector) {
        _hasInspector = NO;
        [super closeInspector:sender];
    } else {
        _hasInspector = YES;
        [super showInspector:sender];
    }
    
    /* Find the Inspector Panel and add an observer to properly handle open/close actions. */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL found = NO;
        for (NSPanel *p in NSApp.windows) {
            if ([p.className isEqualToString:@"IKImageEditPanel"]) {
                p.floatingPanel = NO;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inspectorWillClose:) name:NSWindowWillCloseNotification object:p];
                found = YES;
                break;
            }
            //NSLog(@"window: %@\ntitle: %@\ndelegate: %p", p.description, p.title, p.delegate.description);
        }
        if (!found) {
            NSLog(@"%s: IKImageEditPanel not found", __PRETTY_FUNCTION__);
        }
    });

}

- (IBAction)zoomInOut:(NSButton *)sender {
    NSRect r = self.selectionRect;
    if (_zoomed) {
        [super zoomImageToFit:sender];
        self.autoresizes = YES;
        _zoomed = NO;
        sender.image = [NSImage imageNamed:NSImageNameEnterFullScreenTemplate];
    } else {
        [super zoomImageToActualSize:sender];
        _zoomed = YES;
        sender.image = [NSImage imageNamed:NSImageNameExitFullScreenTemplate];
    }
    self.selectionRect = r;
}

#pragma mark - Notifications

- (void)inspectorWillClose:(NSNotification *)notification {
    _hasInspector = NO;
}

#pragma mark - NSEvent

- (void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    [_delegate imageViewSelectionDidChange:self];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSUInteger modifierFlags = theEvent.modifierFlags;
        u_short keyCode = [theEvent keyCode];
        long deltaX = 0;
        long deltaY = 0;
        long step = (modifierFlags & NSAlternateKeyMask) ? 8 : 1;
        switch (keyCode) {
            case 0x7e:
                deltaY = -step; //up
                break;
            case 0x7d:
                deltaY = step; //down
                break;
            case 0x7b:
                deltaX = -step; //left
                break;
            case 0x7c:
                deltaX = step; //right
                break;
                
            default:
                break;
        }

        if (deltaX || deltaY) {
            NSRect s = self.selectionRect;
            s.origin.x += deltaX;
            s.origin.y -= deltaY;
            self.selectionRect = s;
            [_delegate imageViewSelectionDidChange:self];
        }
}

@end
