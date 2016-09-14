//
//  WYLineChartPoint.m
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYLineChartPoint.h"

@implementation WYLineChartPoint

- (CGPoint)point {
    return CGPointMake(_x, _y);
}

+ (instancetype)point {
    
    return [[self alloc] init];
}
+ (instancetype)makePointWithX:(CGFloat)x y:(CGFloat)y {
    
    WYLineChartPoint *point = [self point];
    point.x = x;
    point.y = y;
    return point;
}

+ (instancetype)pointWithCGPoint:(CGPoint)point {

    return [self makePointWithX:point.x y:point.y];
}

- (id)copyWithZone:(NSZone *)zone {
    
    WYLineChartPoint *newPoint = [[WYLineChartPoint alloc] init];
    newPoint.x = _x;
    newPoint.y = _y;
    newPoint.value = _value;
    newPoint.index = _index;
    return newPoint;
}

@end


@implementation WYLineChartPathSegment

- (BOOL)isContainedPoint:(CGPoint)point {
    
    if (point.x >= _startPoint.x && point.x <= _endPoint.x) {
        return true;
    }
    
    return false;
}

- (CGFloat)yValueCalculteFromQuadraticFormulaForPoint:(CGPoint)point {
    
    CGFloat x = point.x;
    return _coefficientA * powf(x, 2) + _coefficientB * x + _coefficientC;
}

- (WYLineChartPoint *)originalPointForPoint:(CGPoint)point {

    if (_lineStyle == kWYLineChartMainNoneLine) return nil;
    if (point.x < _startPoint.x || point.x > _endPoint.x) return nil;
    
    if (_lineStyle == kWYLineChartMainStraightLine
        || _lineStyle == kWYLineChartMainBezierTaperLine) {
        WYLineChartPoint *newPoint = [WYLineChartPoint makePointWithX:(_startPoint.x+_endPoint.x)/2
                                                                    y:(_startPoint.y+_endPoint.y)/2];
        return newPoint;
    }
    if (_lineStyle == kWYLineChartMainBezierWaveLine) {
        return _isStartPointOriginalPoint ? _startPoint : _endPoint;
    }
    return nil;
}

@end