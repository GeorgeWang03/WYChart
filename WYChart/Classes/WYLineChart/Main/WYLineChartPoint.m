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

+ (NSArray *)pointsFromValueArray:(NSArray *)valueArray {
    if (!valueArray || valueArray.count == 0) {
        return [NSArray array];
    }
    
    WYLineChartPoint *point;
    NSInteger idx = 0;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:valueArray.count];
    for (id value in valueArray) {
        NSAssert([value isKindOfClass:[NSNumber class]], @"point`s value should be a NSNumber object.");
        point = [self point];
        point.value = [value floatValue];
        point.index = idx ++;
        [mutableArray addObject:point];
    }
    return [NSArray arrayWithArray:mutableArray];
}

+ (WYLineChartPoint *)maxValuePointFromArray:(NSArray *)points {
    
    return [self filterPointFromArray:points
                      comparatorBlock:^BOOL(WYLineChartPoint *p1, WYLineChartPoint *p2) {
                          return p1.value < p2.value;
                      }];
    /*__block CGFloat maxValue = -MAXFLOAT;
    __block WYLineChartPoint *maxValuePoint;
    [points enumerateObjectsUsingBlock:^(WYLineChartPoint *point, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([point isKindOfClass:[WYLineChartPoint class]], @"point should be kind of WYLineChartPoint class");
        if (point.value > maxValue) {
            maxValue = point.value;
            maxValuePoint = point;
        }
    }];
    return maxValuePoint;*/
}

+ (WYLineChartPoint *)minValuePointFromArray:(NSArray *)points {
    
    return [self filterPointFromArray:points
                      comparatorBlock:^BOOL(WYLineChartPoint *p1, WYLineChartPoint *p2) {
                          return p1.value > p2.value;
                      }];
    /*__block CGFloat minValue = MAXFLOAT;
    __block WYLineChartPoint *minValuePoint;
    [points enumerateObjectsUsingBlock:^(WYLineChartPoint *point, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([point isKindOfClass:[WYLineChartPoint class]], @"point should be kind of WYLineChartPoint class");
        if (point.value < minValue) {
            minValue = point.value;
            minValuePoint = point;
        }
    }];
    return minValuePoint;*/
}

+ (WYLineChartPoint *)filterPointFromArray:(NSArray *)points comparatorBlock:(BOOL (^)(WYLineChartPoint *, WYLineChartPoint *))comparator {
    if (!points || points.count == 0) {
        return nil;
    }
    
    __block WYLineChartPoint *resultPoint = points[0];
    [points enumerateObjectsUsingBlock:^(WYLineChartPoint *point, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([point isKindOfClass:[WYLineChartPoint class]], @"point should be kind of WYLineChartPoint class");
        if (comparator(point, resultPoint)) {
            resultPoint = point;
        }
    }];
    return resultPoint;
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
