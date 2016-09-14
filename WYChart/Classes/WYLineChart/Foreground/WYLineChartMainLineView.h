//
//  WYLineChartMainLineView.h
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYLineChartView.h"


@class WYLineChartPoint;
@class WYLineChartMainLineView;

@protocol WYLineChartMainLineViewDelegate <NSObject>

@optional
- (void)mainLineView:(WYLineChartMainLineView *)lineView didBeganTouchAtPoint:(CGPoint)point belongToSegmentOfPoint:(WYLineChartPoint *)originalPoint;

- (void)mainLineView:(WYLineChartMainLineView *)lineView didmovedTouchToPoint:(CGPoint)point belongToSegmentOfPoint:(WYLineChartPoint *)originalPoint;

- (void)mainLineView:(WYLineChartMainLineView *)lineView didEndedTouchAtPoint:(CGPoint)point belongToSegmentOfPoint:(WYLineChartPoint *)originalPoint;

@end

@interface WYLineChartMainLineView : UIView

@property (nonatomic, weak) WYLineChartView<WYLineChartMainLineViewDelegate> *parentView;

@property (nonatomic) WYLineChartMainLineStyle style;

@property (nonatomic) UIColor *lineColor;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, copy) NSArray *lineDashPattern;

@property (nonatomic) WYLineChartAnimationStyle animationStyle;
@property (nonatomic) CGFloat animationDuration;

@property (nonatomic) BOOL showJunctionShape;
@property (nonatomic, copy) UIColor *junctionColor;
@property (nonatomic) WYLineChartJunctionShapeStyle junctionStyle;
@property (nonatomic) WYLineChartJunctionShapeSize junctionSize;

@property (nonatomic, copy) UIColor *touchPointColor;
@property (nonatomic) WYLineChartJunctionShapeStyle touchPointStyle;
@property (nonatomic) WYLineChartJunctionShapeSize touchPointSize;

@property (nonatomic, strong) NSArray *pathSegments;

@property (nonatomic, strong) UIView *touchView;

///////--------------------------------------- Color ------------------------------------------///////

@property (nonatomic, strong) UIColor *lineStrokeColor;


@end
