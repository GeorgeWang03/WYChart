//
//  WYSectorLayer.h
//  WYChart
//
//  Created by yingwang on 16/8/16.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WYPieChartView.h"

@class WYPieSector;

@interface WYSectorLayer : CAShapeLayer

@property (nonatomic) BOOL selected;
@property (nonatomic) WYPieChartAnimationStyle animationStyle;

+ (instancetype)layerWithSectorInfo:(WYPieSector *)sector;

- (void)stopAllAnimations;

- (void)addAlphaAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay toValue:(CGFloat)toValue delegate:(id)delegate;

- (void)addStretchAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay delegate:(id)delegate;

- (void)addScaleAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay delegate:(id)delegate;

- (void)addDraggingSpringAnimationWithAmplitude:(CGFloat)amplitude delay:(CGFloat)delay delegate:(id)delegate;

@end
