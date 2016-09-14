//
//  WYLineChartCalculator.m
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYLineChartCalculator.h"
#import "WYLineChartView.h"
#import "WYLineChartPoint.h"

#define MAX_YAxisLabelWidth 90
#define DEFAULT_LabelHeight 35

@implementation WYLineChartCalculator

- (CGFloat)drawableAreaWidth {
    
    if (!_parentView.scrollable) return self.lineGraphWindowWidth;
    
    CGFloat gapBetweenPoints = [_parentView.delegate gapBetweenPointsHorizontalInLineChartView:_parentView];
    
    CGFloat width = (_parentView.points.count - 1) * gapBetweenPoints + _parentView.lineLeftMargin + _parentView.lineRightMargin;
    
    return width > self.lineGraphWindowWidth ? width : self.lineGraphWindowWidth;
}

- (CGFloat)drawableAreaHeight {
    return CGRectGetHeight(_parentView.frame) - self.xAxisLabelHeight - 2;
}

- (CGFloat)lineGraphWindowWidth {
    
    CGFloat width;
    CGFloat yAxisLabelWidth = [self yAxisLabelWidth];
    
    width = CGRectGetWidth(_parentView.frame) - 2 - yAxisLabelWidth;
    
    return width;
}

- (CGFloat)widthOfLabelOnXAxisAtIndex:(NSInteger)index {
    
    CGFloat width;
    CGFloat leftWidth = 0;
    CGFloat rightWidth = 0;
    WYLineChartPoint *p1, *p2, *lastLabelPoint, *lastPoint;
    NSInteger maxIndex;
    
    maxIndex = [_parentView.delegate numberOfLabelOnXAxisInLineChartView:_parentView] - 1;
    lastLabelPoint = [_parentView.datasource lineChartView:_parentView pointReferToXAxisLabelAtIndex:maxIndex];
    lastPoint = [_parentView.points lastObject];
    
    p2 = [_parentView.datasource lineChartView:_parentView pointReferToXAxisLabelAtIndex:index];
    if (p2.index > 0) {
        p1 = [_parentView.datasource lineChartView:_parentView pointReferToXAxisLabelAtIndex:index-1];
        leftWidth = (p2.x - p1.x) / 2;
    } else {
        leftWidth = _parentView.lineLeftMargin;
    }
    
    p1 = [_parentView.datasource lineChartView:_parentView pointReferToXAxisLabelAtIndex:index];
    if (p1.index < lastLabelPoint.index) {
        p2 = [_parentView.datasource lineChartView:_parentView pointReferToXAxisLabelAtIndex:index+1];
        rightWidth = (p2.x - p1.x) / 2;
    } else {
        CGFloat rightAvaliableSpace = lastPoint.x - p1.x + _parentView.lineRightMargin;
        rightWidth = leftWidth > rightAvaliableSpace ? rightAvaliableSpace : leftWidth;
    }
    
    if (p1.index > 0 && p1.index < _parentView.points.count - 1) {
        width = MIN(leftWidth, rightWidth) * 2;
    } else {
        width = leftWidth + rightWidth;
    }
    return width;
}

- (CGFloat)yAxisLabelWidth {
    
    CGFloat maxValueOfPoints = [_parentView.delegate maxValueForPointsInLineChartView:_parentView];
    NSString *valueString = [NSString stringWithFormat:@"%.0f", maxValueOfPoints];
    
    NSDictionary *attributes = @{NSFontAttributeName:_parentView.labelsFont};
    CGSize lableMaxSize = [valueString sizeWithAttributes:attributes];
    
    return lableMaxSize.width + 25.f;
}

- (CGFloat)xAxisLabelHeight {
    
    return DEFAULT_LabelHeight;
}

- (CGFloat)yAxisLabelHeight {
    
    return DEFAULT_LabelHeight;
}

- (CGFloat)yAxisViewWidth {
    return self.yAxisLabelWidth + 3.f;
}

- (CGFloat)xLocationForPointAtIndex:(NSInteger)index {
    
    CGFloat x;
    CGFloat gap;
    
    if (_parentView.scrollable) {
        gap = [_parentView.delegate gapBetweenPointsHorizontalInLineChartView:_parentView];
    } else {
        gap = (self.drawableAreaWidth - _parentView.lineLeftMargin - _parentView.lineRightMargin) / (_parentView.points.count - 1);
    }
    
    x = _parentView.lineLeftMargin + gap * index;
    x = roundf(x);
    
    return x;
}

- (CGFloat)yLocationForPointAtIndex:(NSInteger)index {
    
    WYLineChartPoint *point = _parentView.points[index];
    
    return [self yLocationForPointsValue:point.value];
}

- (CGFloat)yLocationForPointsValue:(CGFloat)value {
    
    CGFloat y;
    CGFloat maxValue = [_parentView.delegate maxValueForPointsInLineChartView:_parentView];
    CGFloat minValue = [_parentView.delegate minValueForPointsInLineChartView:_parentView];
    CGFloat differ = maxValue - minValue;
    CGFloat pixels = self.drawableAreaHeight - (_parentView.lineTopMargin + 30.f) - _parentView.lineBottomMargin;
    
    y = (_parentView.lineTopMargin + 30.f) + (maxValue - value) * pixels / differ;
    y = roundf(y);
    
    return y;
}

- (void)recaclculatePointsCoordinate {
    
    if (_parentView.points.count == 0) return;
    
    [_parentView.points enumerateObjectsUsingBlock:^(WYLineChartPoint * point, NSUInteger idx, BOOL * _Nonnull stop) {
        
        point.index = (NSInteger)idx;
        point.y = [self yLocationForPointAtIndex:idx];
        point.x = [self xLocationForPointAtIndex:idx];
    }];
}

- (NSArray *)recalculatePathSegmentsForPoints:(NSArray *)points withLineStyle:(WYLineChartMainLineStyle)lineStyle {
   
    if (points.count < 2) return nil;
    
    NSMutableArray *segments = [NSMutableArray array];
    
    WYLineChartPoint *currentPoint;
    WYLineChartPoint *newPoint;
    
    currentPoint = points[0];
    
    for (NSInteger idx = 1; idx < points.count; ++idx) {
        
        newPoint = points[idx];
        
        CGPoint controlPointPre, controlPointSub;
        CGPoint midPoint = [self middlePointBetweenPoint:currentPoint.point andPoint:newPoint.point];
        
        WYLineChartPathSegment *segment;
        
        if (lineStyle == kWYLineChartMainBezierWaveLine) {
            if (currentPoint.y > newPoint.y) {
                
                controlPointPre = [_parentView.calculator higherControlPointBetweenPoint:currentPoint.point andPoint:midPoint];
                controlPointSub = [_parentView.calculator lowerControlPointBetweenPoint:midPoint andPoint:newPoint.point];
            } else {
                
                controlPointPre = [_parentView.calculator lowerControlPointBetweenPoint:currentPoint.point andPoint:midPoint];
                controlPointSub = [_parentView.calculator higherControlPointBetweenPoint:midPoint andPoint:newPoint.point];
            }
            
            segment = [[WYLineChartPathSegment alloc] init];
            segment.lineStyle = lineStyle;
            segment.isStartPointOriginalPoint = true;
            segment.startPoint = currentPoint;
            segment.endPoint = [WYLineChartPoint pointWithCGPoint:midPoint];
            segment.controlPoint = [WYLineChartPoint pointWithCGPoint:controlPointPre];
            [self calculateQuadraticFormulaCoefficents:segment];
            [segments addObject:segment];
            
            segment = [[WYLineChartPathSegment alloc] init];
            segment.lineStyle = lineStyle;
            segment.isStartPointOriginalPoint = false;
            segment.startPoint = [WYLineChartPoint pointWithCGPoint:midPoint];
            segment.endPoint = newPoint;
            segment.controlPoint = [WYLineChartPoint pointWithCGPoint:controlPointSub];
            [self calculateQuadraticFormulaCoefficents:segment];
            [segments addObject:segment];
        } else if (lineStyle == kWYLineChartMainStraightLine) {
            
            segment = [[WYLineChartPathSegment alloc] init];
            segment.lineStyle = lineStyle;
            segment.startPoint = currentPoint;
            segment.endPoint = newPoint;
            [self calculateQuadraticFormulaCoefficents:segment];
            [segments addObject:segment];
        } else if(lineStyle == kWYLineChartMainBezierTaperLine) {
            segment = [[WYLineChartPathSegment alloc] init];
            segment.lineStyle = lineStyle;
            segment.startPoint = currentPoint;
            segment.endPoint = newPoint;
            segment.controlPoint = [WYLineChartPoint pointWithCGPoint:[self higherControlPointBetweenPoint:currentPoint.point andPoint:newPoint.point]];
            [self calculateQuadraticFormulaCoefficents:segment];
            [segments addObject:segment];
        }
        
        currentPoint = newPoint;
    }
    return segments;
}

- (void)calculateQuadraticFormulaCoefficents:(WYLineChartPathSegment *)segment {
    
    CGPoint p1, p2, p3;
    p1 = segment.startPoint.point;
    p2 = segment.controlPoint.point;
    p3 = segment.endPoint.point;
    
    if (segment.lineStyle == kWYLineChartMainBezierWaveLine
        || segment.lineStyle == kWYLineChartMainBezierTaperLine) {
        // Convert quadratic bezier curve to parabola
        // reference : (http://math.stackexchange.com/questions/1257576/convert-quadratic-bezier-curve-to-parabola)
        // here we are sure that x2 = (x1+x3)/2
        
        segment.coefficientA = (p1.y - 2 * p2.y + p3.y) / powf((p3.x - p1.x), 2);
        segment.coefficientB = 2 * (p3.x*(p2.y - p1.y) + p1.x*(p2.y - p3.y)) / powf((p3.x - p1.x), 2);
        segment.coefficientC = p1.y - segment.coefficientA * powf(p1.x, 2) - segment.coefficientB * p1.x;
    } else if (segment.lineStyle == kWYLineChartMainStraightLine) {
        segment.coefficientA = 0;
        segment.coefficientB = (p3.y - p1.y) / (p3.x - p1.x);
        segment.coefficientC = p1.y - segment.coefficientB * p1.x;
    }
}

- (WYLineChartPoint *)maxValueOfPoints:(NSArray *)points {
    
    if (!points.count) return nil;
    
    WYLineChartPoint *maxPoint;
    WYLineChartPoint *currentPoint;
    maxPoint = points[0];
    
    for (NSInteger idx = 1; idx < points.count; ++idx) {
        
        currentPoint = points[idx];
        if (currentPoint.value > maxPoint.value) {
            maxPoint = currentPoint;
        }
    }
    return maxPoint;
}

- (WYLineChartPathSegment *)segmentForPoint:(CGPoint)point inSegments:(NSArray *)segments {
    
    if (!segments.count) return nil;
    
    WYLineChartPathSegment *segment;
    for (WYLineChartPathSegment *obj in segments) {
        if (obj.startPoint.x <= point.x
            && obj.endPoint.x >= point.x) {
            segment = obj;
            break;
        }
    }
    return segment;
}

///////--------------------------------------- About Bezier Path ------------------------------------------///////

- (CGPoint)middlePointBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
    return CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
}

- (CGPoint)lowerControlPointBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
    
    CGPoint newPoint;
    
    newPoint.y = p1.y > p2.y ? p2.y : p1.y;
    newPoint.x = (p1.x + p2.x)/2;
    
    return newPoint;
}

- (CGPoint)higherControlPointBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
    
    CGPoint newPoint;
    newPoint.y = p1.y > p2.y ? p1.y : p2.y;
    newPoint.x = (p1.x + p2.x)/2;
    return newPoint;
}

///////--------------------------------------- About Values ------------------------------------------///////

- (CGFloat)calculateAverageForPoints:(NSArray *)points {
    
    CGFloat average = 0;
    __block CGFloat sum = 0;
    [points enumerateObjectsUsingBlock:^(WYLineChartPoint * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sum += obj.value;
    }];
    
    average = (CGFloat)sum / points.count;
    
    return average;
}

- (CGFloat)verticalLocationForValue:(CGFloat)average {
    return [self yLocationForPointsValue:average];
}

- (CGFloat)valueReferToVerticalLocation:(CGFloat)location {
    
    CGFloat value;
    CGFloat maxValue = [_parentView.delegate maxValueForPointsInLineChartView:_parentView];
    CGFloat minValue = [_parentView.delegate minValueForPointsInLineChartView:_parentView];
    CGFloat differ = maxValue - minValue;
    CGFloat pixels = self.drawableAreaHeight - (_parentView.lineTopMargin + 30.f) - _parentView.lineBottomMargin;
    
    value = maxValue - (location - (_parentView.lineTopMargin + 30.f)) * differ / pixels;
    return value;
}

@end
