//
//  WYLineChartPoint.h
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYLineChartView.h"
@import UIKit;

@interface WYLineChartPoint : NSObject <NSCopying>

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

@property (nonatomic) CGFloat value;
@property (nonatomic) NSInteger index;

@property (nonatomic, readonly) CGPoint point;

+ (instancetype)point;
+ (instancetype)makePointWithX:(CGFloat)x y:(CGFloat)y;
+ (instancetype)pointWithCGPoint:(CGPoint)point;

@end


@interface WYLineChartPathSegment : NSObject

@property (nonatomic) WYLineChartPoint *startPoint;
@property (nonatomic) WYLineChartPoint   *endPoint;
@property (nonatomic) WYLineChartPoint *controlPoint;

@property (nonatomic) CGFloat coefficientA;
@property (nonatomic) CGFloat coefficientB;
@property (nonatomic) CGFloat coefficientC;

@property (nonatomic) WYLineChartMainLineStyle lineStyle;
// this property only effect when lineStyle is kWYLineChartMainBezierWaveLine,
// if true, startPoint is originalPoint, otherwise endPoint.
@property (nonatomic) BOOL isStartPointOriginalPoint;

// judge if point.x between startPoint.x and end endPoint.x
- (BOOL)isContainedPoint:(CGPoint)point;

//
- (CGFloat)yValueCalculteFromQuadraticFormulaForPoint:(CGPoint)point;

- (WYLineChartPoint *)originalPointForPoint:(CGPoint)point;

@end