//
//  WYLineChartCoordinateView.m
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYLineChartCoordinateView.h"
#import "WYLineChartView.h"
#import "WYLineChartCalculator.h"
#import "WYLineChartPoint.h"

@interface WYLineChartCoordinateView ()

@end

@implementation WYLineChartCoordinateView

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    self.backgroundColor = [UIColor clearColor];
//}

@end

@implementation WYLineChartCoordinateXAXisView

- (void)drawRect:(CGRect)rect {
    
    /**
     *	clean sublayer and subview
     */
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    /**
     *	Draw Lables
     */
    NSInteger labelCount = [self.parentView.delegate numberOfLabelOnXAxisInLineChartView:self.parentView];
    NSAssert(labelCount < self.parentView.points.count, @"WYLineChartCoordinateYAXisView : labels count can't more than line's points count");
    
    UILabel *label;
    CGFloat centerX, centerY;
    CGFloat labelWidth;
    CGFloat labelHeight = self.parentView.calculator.xAxisLabelHeight;
    WYLineChartPoint *point;
    
    for (NSInteger idx = 0; idx < labelCount; ++idx) {
        
        point = [self.parentView.datasource lineChartView:self.parentView pointReferToXAxisLabelAtIndex:idx];
        
        labelWidth = [self.parentView.calculator widthOfLabelOnXAxisAtIndex:idx];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
        
        centerY = labelHeight / 2;
        
        if (point.index == 0) {
            centerX = point.x + labelWidth/2 - self.parentView.lineLeftMargin;
        } else if(point.index == self.parentView.points.count - 1) {
            centerX = point.x - labelWidth/2 + self.parentView.lineLeftMargin;
        } else {
            centerX = point.x;
        }
        
        
        label.center = CGPointMake(centerX, centerY);
        
        label.font = self.parentView.labelsFont;
        label.textColor = self.parentView.labelsColor;
//        label.backgroundColor = [UIColor clearColor];
        label.text = [self.parentView.datasource lineChartView:self.parentView contentTextForXAxisLabelAtIndex:idx];
        
        NSTextAlignment alignment = NSTextAlignmentCenter;
        if (point.index == 0) {
            //leftest label
            alignment = NSTextAlignmentJustified;
        } else if(point.index == self.parentView.points.count - 1) {
            //rightest label
            alignment = NSTextAlignmentJustified;
        }
        label.textAlignment = alignment;
        
        [self addSubview:label];
    }
}

@end

@implementation WYLineChartCoordinateYAXisView

- (void)drawRect:(CGRect)rect {
    
    /**
     *	clean sublayer and subview
     */
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    /**
     *	Draw Y Axis
     */
    CGFloat yAxisWidth = self.parentView.calculator.yAxisViewWidth;
    CGFloat yAxisHeight = self.parentView.calculator.drawableAreaHeight;
    
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake(yAxisWidth, 0)];
    [line addLineToPoint:CGPointMake(yAxisWidth, yAxisHeight)];
    
    CAShapeLayer *yAxisLayer = [CAShapeLayer layer];
    yAxisLayer.frame = self.bounds;
    yAxisLayer.path = line.CGPath;
    yAxisLayer.lineWidth = 1.0;
    yAxisLayer.opacity = 0.7;
    yAxisLayer.strokeColor = self.parentView.axisColor.CGColor;
    
    [self.layer addSublayer:yAxisLayer];
    
    /**
     *	Draw Lables
     */
    NSInteger labelCount = [self.parentView.delegate numberOfReferenceLineHorizontalInLineChartView:self.parentView];
    NSAssert(labelCount < self.parentView.points.count, @"WYLineChartCoordinateYAXisView : labels count can't more than line's points count");
    
    UILabel *label;
    CGFloat centerX, centerY;
    CGFloat labelWidth = self.parentView.calculator.yAxisLabelWidth;
    CGFloat labelHeight = self.parentView.calculator.yAxisLabelHeight;
    
    centerX = labelWidth / 2;
    
    
    CGFloat yValue, yLocation;
    
    for (NSInteger idx = 0; idx < labelCount; ++idx) {
        
        yValue = [self.parentView.datasource lineChartView:self.parentView valueReferToHorizontalReferenceLineAtIndex:idx];
        yLocation = [self.parentView.calculator verticalLocationForValue:yValue];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
        centerY = yLocation;
        label.center = CGPointMake(centerX, centerY);
        
        label.font = self.parentView.labelsFont;
        label.textColor = self.parentView.labelsColor;
//        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%.2f", yValue];
        
        NSTextAlignment alignment = NSTextAlignmentRight;
        label.textAlignment = alignment;
        
        [self addSubview:label];
    }
    
    //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *//
    //                   Configure y axis prefix and suffix                  //
    //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *//
    
    if (self.parentView.yAxisHeaderPrefix) {
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
        label.font = self.parentView.labelsFont;
        label.textColor = self.parentView.labelsColor;
        label.backgroundColor = [UIColor clearColor];
        label.text = self.parentView.yAxisHeaderPrefix;
        
        NSTextAlignment alignment = NSTextAlignmentCenter;
        label.textAlignment = alignment;
        
        [self addSubview:label];
    }
    
    if (self.parentView.yAxisHeaderSuffix) {
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.frame) - self.parentView.calculator.xAxisLabelHeight - 2, labelWidth, self.parentView.calculator.xAxisLabelHeight)];
        label.font = self.parentView.labelsFont;
        label.textColor = self.parentView.labelsColor;
        label.backgroundColor = [UIColor clearColor];
        label.text = self.parentView.yAxisHeaderSuffix;
        
        NSTextAlignment alignment = NSTextAlignmentCenter;
        label.textAlignment = alignment;
        
        [self addSubview:label];
    }
}

@end