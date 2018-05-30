//
//  FFHBitrateCalc.h
//  ffmpegHelper
//
//  Created by Terminator on 2018/05/16.
//  Copyright © 2018年 Terminator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol FFHBitrateCalcDelegate;

@interface FFHBitrateCalc : NSWindowController

@property id <FFHBitrateCalcDelegate> delegate;

@end

@protocol FFHBitrateCalcDelegate <NSObject>

- (float)mediaLengthForBitrateCalc:(FFHBitrateCalc *)calc;

@end
