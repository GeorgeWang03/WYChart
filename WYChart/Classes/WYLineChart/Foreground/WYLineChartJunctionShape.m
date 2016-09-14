//
//  WYLineChartCircle.m
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYLineChartJunctionShape.h"

@interface WYLineChartJunctionShape ()
{
    WYLineChartJunctionShapeStyle _style;
    CAShapeLayer *sublayer;
}

@end

#define DEFAULT_LINE_WIDTH 2

@implementation WYLineChartJunctionShape

- (instancetype)initWithStyle:(WYLineChartJunctionShapeStyle)style size:(WYLineChartJunctionShapeSize)size origin:(CGPoint)origin {
    
    CGRect frame;
    frame.origin = origin;
    
    switch (size) {
        case kWYLineChartJunctionSmallShape:
            frame.size = CGSizeMake(6, 6);
            break;
        case kWYLineChartJunctionMiddleShape:
            frame.size = CGSizeMake(12, 12);
            break;
        case kWYLineChartJunctionLargeShape:
            frame.size = CGSizeMake(24, 24);
            break;
        default:
            break;
    }
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _style = style;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
   
    CGColorRef strokeColor = _strokeColor.CGColor;
    CGColorRef fillColor = _fillColor.CGColor;
    
    CGFloat boundLength = CGRectGetWidth(self.bounds);
    if (sublayer) {
        [sublayer removeFromSuperlayer];
    }
    
    void(^drawLayer)(UIBezierPath *path, BOOL isSolid) = ^(UIBezierPath *path, BOOL isSolid) {
        
        sublayer = [CAShapeLayer layer];
        sublayer.path = path.CGPath;
        sublayer.strokeColor = strokeColor;
        sublayer.lineWidth = DEFAULT_LINE_WIDTH;
        sublayer.lineJoin = kCALineCapRound;
        
        if (isSolid) {
            sublayer.fillColor = fillColor;
        } else {
            sublayer.fillColor = [UIColor clearColor].CGColor;
        }
        
        [self.layer  addSublayer:sublayer];
    };
    
    void(^drawCircle)(BOOL isSolid) = ^(BOOL isSolid) {
        
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, boundLength, boundLength)];
        drawLayer(path, isSolid);
    };
    
    void(^drawSquare)(BOOL isSolid) = ^(BOOL isSolid) {
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, boundLength, boundLength)];
        drawLayer(path, isSolid);
    };
    
    void(^drawRectangle)(BOOL isSolid) = ^(BOOL isSolid) {
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(boundLength / 2, 0)];
        [path addLineToPoint:CGPointMake(0, boundLength)];;
        [path addLineToPoint:CGPointMake(boundLength, boundLength)];
        [path addLineToPoint:CGPointMake(boundLength / 2, 0)];
        
        drawLayer(path, isSolid);
    };
    
    void(^drawStar)(BOOL isSolid) = ^(BOOL isSolid) {
        
        CGFloat c = boundLength / 70;
        UIBezierPath* starPath = [UIBezierPath bezierPath];
        [starPath moveToPoint: CGPointMake(45.25*c, 0)];
        [starPath addLineToPoint: CGPointMake(61.13*c, 23*c)];
        [starPath addLineToPoint: CGPointMake(88.29*c, 30.75*c)];
        [starPath addLineToPoint: CGPointMake(70.95*c, 52.71*c)];
        [starPath addLineToPoint: CGPointMake(71.85*c, 80.5*c)];
        [starPath addLineToPoint: CGPointMake(45.25*c, 71.07*c)];
        [starPath addLineToPoint: CGPointMake(18.65*c, 80.5*c)];
        [starPath addLineToPoint: CGPointMake(19.55*c, 52.71*c)];
        [starPath addLineToPoint: CGPointMake(2.21*c, 30.75*c)];
        [starPath addLineToPoint: CGPointMake(29.37*c, 23*c)];
        [starPath closePath];
        drawLayer(starPath, isSolid);
    };
    
    switch (_style) {
        case kWYLineChartJunctionShapeSolidCircle:
            drawCircle(true);
            break;
        case kWYLineChartJunctionShapeHollowCircle:
            drawCircle(false);
            break;
        case kWYLineChartJunctionShapeSolidSquare:
            drawSquare(true);
            break;
        case kWYLineChartJunctionShapeHollowSquare:
            drawSquare(false);
            break;
        case kWYLineChartJunctionShapeSolidRectangle:
            drawRectangle(true);
            break;
        case kWYLineChartJunctionShapeHollowRectangle:
            drawRectangle(false);
            break;
        case kWYLineChartJunctionShapeSolidStar:
            drawStar(true);
            break;
        case kWYLineChartJunctionShapeHollowStar:
            drawStar(false);
            break;
        default:
            break;
    }
}
@end
