//
//  WYLineChartReferenceLineView.m
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYLineChartReferenceLineView.h"
#import "WYLineChartView.h"
#import "WYLineChartCalculator.h"
#import "WYLineChartPoint.h"


#define DEFAULT_LINE_WIDTH  2

@interface WYLineChartReferenceLineView ()

@property (nonatomic, strong) UIView *movingView;

@end

@implementation WYLineChartReferenceLineView

- (void)shapeLayer:(CAShapeLayer *)layer addAnimationForKeyPath:(NSString *)keyPath fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue {
    
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.duration = _animationDuration;
    animation.fromValue = @(fromValue);
    animation.toValue = @(toValue);
    
    [layer addAnimation:animation forKey:keyPath];
}

- (void)dismissReferenceLine {
    
    _movingView.hidden = YES;
}

- (void)moveReferenceLineToPoint:(CGPoint)point {}

@end

@implementation WYLineChartHorizontalReferenceLineView

- (void)drawRect:(CGRect)rect {
    
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    
    
    //CGFloat average = [self.parentView.calculator calculateAverageForPoints:self.parentView.points];
    //CGFloat verticalLocation = [self.parentView.calculator verticalLocationForValue:average];
    
    //remove sublayer
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    /**
     *	Draw X Axis
     */
    CGFloat xAxisWidth = self.parentView.calculator.drawableAreaWidth;
    
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake(0, boundsHeight)];
    [line addLineToPoint:CGPointMake(xAxisWidth, boundsHeight)];
    
    CAShapeLayer *xAxisLayer = [CAShapeLayer layer];
    xAxisLayer.frame = self.bounds;
    xAxisLayer.path = line.CGPath;
    xAxisLayer.lineWidth = 1.0;
    xAxisLayer.opacity = 0.7;
    xAxisLayer.strokeColor = self.parentView.axisColor.CGColor;
    
    [self.layer addSublayer:xAxisLayer];
    
    //* * * * * * * * * * * * * * * * * * * *//
    //         Draw Average Line             //
    //* * * * * * * * * * * * * * * * * * * *//
    /*
    CAShapeLayer *averageLineLayer;
    UIBezierPath *averageLinePath;
    
    averageLinePath = [UIBezierPath bezierPath];
    [averageLinePath moveToPoint:CGPointMake(0, verticalLocation)];
    [averageLinePath addLineToPoint:CGPointMake(boundsWidth, verticalLocation)];
    
    averageLineLayer = [CAShapeLayer layer];
    averageLineLayer.path = averageLinePath.CGPath;
    averageLineLayer.strokeColor = self.averageLineColor.CGColor;
    averageLineLayer.lineWidth = self.averageLineWidth;
    averageLineLayer.opacity = self.averageLineAlpha;
    
    if (self.averageLineDashPattern) averageLineLayer.lineDashPattern = self.averageLineDashPattern;
    
    [self.layer addSublayer:averageLineLayer];*/
    
    //* * * * * * * * * * * * * * * * * * * *//
    //         Draw Reference Line           //
    //* * * * * * * * * * * * * * * * * * * *//
    
    NSInteger horizontalLineCount = 0;
    
    if ([self.parentView.delegate respondsToSelector:@selector(numberOfReferenceLineHorizontalInLineChartView:)]) {
        horizontalLineCount = [self.parentView.delegate numberOfReferenceLineHorizontalInLineChartView:self.parentView];
    }
    
    CGFloat yValue;
    CGFloat yLocation;
    UIBezierPath *horizontalReferencePath;
    CAShapeLayer *horizontalReferenceLineLayer;
    
    if (horizontalLineCount > 0) {
        
        horizontalReferenceLineLayer = [CAShapeLayer layer];
        horizontalReferencePath = [UIBezierPath bezierPath];
        
        for (NSInteger idx = 0; idx < horizontalLineCount; ++idx) {
            yValue = [self.parentView.datasource lineChartView:self.parentView valueReferToHorizontalReferenceLineAtIndex:idx];
            yLocation = [self.parentView.calculator verticalLocationForValue:yValue];
            [horizontalReferencePath moveToPoint:CGPointMake(0, yLocation)];
            [horizontalReferencePath addLineToPoint:CGPointMake(boundsWidth, yLocation)];
        }
        
        horizontalReferenceLineLayer.path = horizontalReferencePath.CGPath;
        horizontalReferenceLineLayer.strokeColor = self.horizontalRefernenceLineColor.CGColor;
        horizontalReferenceLineLayer.lineWidth = self.horizontalReferenceLineWidth;
        horizontalReferenceLineLayer.opacity = self.horizontalReferenceLineAlpha;
        if (self.horizontalReferenceLineDashPattern) horizontalReferenceLineLayer.lineDashPattern = self.horizontalReferenceLineDashPattern;
        
        [self.layer addSublayer:horizontalReferenceLineLayer];
    }
    
    // draw moving reference line
    self.movingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, boundsWidth, 2)];
    self.movingView.backgroundColor = [UIColor clearColor];
    
    CAShapeLayer *movingReferenceLineLayer;
    UIBezierPath *movingPath = [UIBezierPath bezierPath];
    [movingPath moveToPoint:CGPointZero];
    [movingPath addLineToPoint:CGPointMake(boundsWidth, 0)];
    movingReferenceLineLayer = [CAShapeLayer layer];
    movingReferenceLineLayer.path = movingPath.CGPath;
    movingReferenceLineLayer.strokeColor = self.touchReferenceLineColor.CGColor;
    movingReferenceLineLayer.lineDashPattern = self.touchReferenceLineDashPattern;
    movingReferenceLineLayer.lineWidth = self.touchReferenceLineWidth;
    movingReferenceLineLayer.opacity = self.touchReferenceLineAlpha;
    [self.movingView.layer addSublayer:movingReferenceLineLayer];
    [self addSubview:self.movingView];
    self.movingView.hidden = true;
    //* * * * * * * * * * * * * * * * * * * *//
    //               Animations              //
    //* * * * * * * * * * * * * * * * * * * *//
    
    if (self.animationStyle != kWYLineChartNoneAnimation) {
        
        CGFloat averageToValue;
        CGFloat horizontalToValue;
        NSString *keyPath;
        
        averageToValue = 0;
        horizontalToValue = 0;
        
        if (self.animationStyle == kWYLineChartAnimationDrawing) {
            
            keyPath = @"strokeEnd";
            averageToValue = 1;
            horizontalToValue = 1;
        } else if (self.animationStyle == kWYLineChartAnimationWidth) {
            
            keyPath = @"lineWidth";
            averageToValue = self.averageLineWidth;
            horizontalToValue = self.horizontalReferenceLineAlpha;
        } else {
            keyPath = @"opacity";
            averageToValue = self.averageLineAlpha;
            horizontalToValue = self.horizontalReferenceLineAlpha;
        }
        
        //[self shapeLayer:averageLineLayer addAnimationForKeyPath:keyPath
        //       fromValue:0.0 toValue:averageToValue];
        [self shapeLayer:horizontalReferenceLineLayer addAnimationForKeyPath:keyPath
               fromValue:0.0 toValue:horizontalToValue];
    }
}

- (void)moveReferenceLineToPoint:(CGPoint)point {

    self.movingView.center = CGPointMake(self.movingView.center.x, point.y);
    self.movingView.hidden = false;
}

@end

@implementation WYLineChartVerticalReferenceLineView

- (void)drawRect:(CGRect)rect {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
#pragma clang diagnostic pop
    
    //remove sublayer
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

    //* * * * * * * * * * * * * * * * * * * *//
    //         Draw Reference Line           //
    //* * * * * * * * * * * * * * * * * * * *//
    
    NSInteger verticalLineCount = 0;
    
    if ([self.parentView.delegate respondsToSelector:@selector(numberOfReferenceLineVerticalInLineChartView:)]) {
        verticalLineCount = [self.parentView.delegate numberOfReferenceLineVerticalInLineChartView:self.parentView];
    }
    
    WYLineChartPoint *point;
    UIBezierPath *verticalReferencePath;
    CAShapeLayer *verticalReferenceLineLayer;
    
    if (verticalLineCount > 0) {
        
        verticalReferenceLineLayer = [CAShapeLayer layer];
        verticalReferencePath = [UIBezierPath bezierPath];
        
        for (NSInteger idx = 0; idx < verticalLineCount; ++idx) {
            point = [self.parentView.datasource lineChartView:self.parentView pointReferToVerticalReferenceLineAtIndex:idx];
            [verticalReferencePath moveToPoint:CGPointMake(point.x, 0)];
            [verticalReferencePath addLineToPoint:CGPointMake(point.x, boundsHeight)];
        }
        
        verticalReferenceLineLayer.path = verticalReferencePath.CGPath;
        verticalReferenceLineLayer.strokeColor = self.verticalReferenceLineColor.CGColor;
        verticalReferenceLineLayer.lineWidth = self.verticalReferenceLineWidth;
        verticalReferenceLineLayer.opacity = self.verticalReferenceLineAlpha;
        if (self.verticalReferenceLineDashPattern) verticalReferenceLineLayer.lineDashPattern = self.verticalReferenceLineDashPattern;
        
        [self.layer addSublayer:verticalReferenceLineLayer];
    }
    
    // draw moving reference line
    self.movingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, boundsHeight)];
    self.movingView.backgroundColor = [UIColor clearColor];
    
    CAShapeLayer *movingReferenceLineLayer;
    UIBezierPath *movingPath = [UIBezierPath bezierPath];
    [movingPath moveToPoint:CGPointZero];
    [movingPath addLineToPoint:CGPointMake(0, boundsHeight)];
    movingReferenceLineLayer = [CAShapeLayer layer];
    movingReferenceLineLayer.path = movingPath.CGPath;
    movingReferenceLineLayer.strokeColor = self.touchReferenceLineColor.CGColor;
    movingReferenceLineLayer.lineDashPattern = self.touchReferenceLineDashPattern;
    movingReferenceLineLayer.lineWidth = self.touchReferenceLineWidth;
    movingReferenceLineLayer.opacity = self.touchReferenceLineAlpha;
    [self.movingView.layer addSublayer:movingReferenceLineLayer];
    [self addSubview:self.movingView];
    self.movingView.hidden = true;
    
    //* * * * * * * * * * * * * * * * * * * *//
    //               Animations              //
    //* * * * * * * * * * * * * * * * * * * *//
    
    if (self.animationStyle != kWYLineChartNoneAnimation) {
        
        CGFloat verticalToValue;
        NSString *keyPath;
        
        verticalToValue = 0;
        
        if (self.animationStyle == kWYLineChartAnimationDrawing) {
            
            keyPath = @"strokeEnd";
            verticalToValue = 1;
        } else if (self.animationStyle == kWYLineChartAnimationWidth) {
            
            keyPath = @"lineWidth";
            verticalToValue = self.verticalReferenceLineWidth;
        } else {
            
            keyPath = @"opacity";
            verticalToValue = self.verticalReferenceLineAlpha;
        }
        
        
        [self shapeLayer:verticalReferenceLineLayer addAnimationForKeyPath:keyPath
               fromValue:0.0 toValue:verticalToValue];
    }
}

- (void)moveReferenceLineToPoint:(CGPoint)point {
    
    self.movingView.center = CGPointMake(point.x, self.movingView.center.y);
    self.movingView.hidden = false;
}

@end
