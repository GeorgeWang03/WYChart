//
//  WYLineChartView.h
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYLineChartJunctionShape.h"

@class WYLineChartView;
@class WYLineChartPoint;
@class WYLineChartCalculator;

typedef NS_ENUM(NSUInteger, WYLineChartAnimationStyle) {
    
    kWYLineChartAnimationDrawing,
    kWYLineChartAnimationAlpha,
    kWYLineChartAnimationWidth,
    kWYLineChartAnimationRise,
    kWYLineChartAnimationSpring,
    kWYLineChartNoneAnimation
};

typedef NS_ENUM(NSUInteger, WYLineChartMainLineStyle) {
    
    kWYLineChartMainStraightLine,
    
    kWYLineChartMainBezierWaveLine,
    
    kWYLineChartMainBezierTaperLine,
    
    kWYLineChartMainNoneLine
};

typedef NS_OPTIONS(NSUInteger, WYLineChartViewScaleOption) {
    
    kWYLineChartViewScaleNarrow = 1 << 0,
    
    kWYLineChartViewScaleLarge = 1 << 1,
    
    kWYLineChartViewScaleNoChange = 1 << 2
};

@protocol WYLineChartViewDelegate <NSObject>

@required

- (NSInteger)numberOfLabelOnXAxisInLineChartView:(WYLineChartView *)chartView;

- (NSInteger)numberOfLabelOnYAxisInLineChartView:(WYLineChartView *)chartView;

- (CGFloat)gapBetweenPointsHorizontalInLineChartView:(WYLineChartView *)chartView;

- (CGFloat)maxValueForPointsInLineChartView:(WYLineChartView *)chartView;

- (CGFloat)minValueForPointsInLineChartView:(WYLineChartView *)chartView;

@optional

- (NSInteger)numberOfReferenceLineVerticalInLineChartView:(WYLineChartView *)chartView;

- (NSInteger)numberOfReferenceLineHorizontalInLineChartView:(WYLineChartView *)chartView;

- (void)lineChartView:(WYLineChartView *)lineView didBeganTouchAtSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value;

- (void)lineChartView:(WYLineChartView *)lineView didMovedTouchToSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value;

- (void)lineChartView:(WYLineChartView *)lineView didEndedTouchToSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value;

- (void)lineChartView:(WYLineChartView *)lineView didBeganPinchWithScale:(CGFloat)scale;

- (void)lineChartView:(WYLineChartView *)lineView didChangedPinchWithScale:(CGFloat)scale;

- (void)lineChartView:(WYLineChartView *)lineView didEndedPinchGraphWithOption:(WYLineChartViewScaleOption)option scale:(CGFloat)scale;

@end

@protocol WYLineChartViewDatasource <NSObject>

@required

- (NSString *)lineChartView:(WYLineChartView *)chartView contentTextForXAxisLabelAtIndex:(NSInteger)index;

- (WYLineChartPoint *)lineChartView:(WYLineChartView *)chartView pointReferToXAxisLabelAtIndex:(NSInteger)index;

@optional

- (WYLineChartPoint *)lineChartView:(WYLineChartView *)chartView pointReferToVerticalReferenceLineAtIndex:(NSInteger)index;

- (CGFloat)lineChartView:(WYLineChartView *)chartView valueReferToHorizontalReferenceLineAtIndex:(NSInteger)index;

@end

@interface WYLineChartView : UIView

///////--------------------------------- Settable Property ------------------------------------///////

@property (nonatomic, weak) id<WYLineChartViewDelegate> delegate;

@property (nonatomic, weak) id<WYLineChartViewDatasource> datasource;
//all the points on the graph
@property (nonatomic, strong) NSArray *points;
//means if the line graph can scroll
//default YES.
@property (nonatomic) BOOL scrollable;
//default NO
@property (nonatomic) BOOL pinchable;

@property (nonatomic) CGFloat lineLeftMargin;
@property (nonatomic) CGFloat lineRightMargin;
@property (nonatomic) CGFloat lineTopMargin;
@property (nonatomic) CGFloat lineBottomMargin;

@property (nonatomic) UIColor *lineColor;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, copy) NSArray *lineDashPattern;

@property (nonatomic, strong) UIFont *labelsFont;
@property (nonatomic, strong) UIColor *labelsColor;

@property (nonatomic, strong) UIColor *axisColor;

@property (nonatomic, strong) NSString *yAxisHeaderPrefix;
@property (nonatomic, strong) NSString *yAxisHeaderSuffix;

// define if drawing gradient below line, default is YES.
@property (nonatomic) BOOL drawGradient;
@property (nonatomic, copy) NSArray *gradientColors;
@property (nonatomic, copy) NSArray *gradientColorsLocation;

@property (nonatomic) WYLineChartAnimationStyle animationStyle;
@property (nonatomic) CGFloat animationDuration;

@property (nonatomic) WYLineChartMainLineStyle lineStyle;

@property (nonatomic) BOOL showJunctionShape;
@property (nonatomic) WYLineChartJunctionShapeStyle junctionStyle;
@property (nonatomic) WYLineChartJunctionShapeSize junctionSize;
@property (nonatomic, copy) UIColor *junctionColor;

@property (nonatomic) WYLineChartJunctionShapeStyle touchPointStyle;
@property (nonatomic) WYLineChartJunctionShapeSize touchPointSize;
@property (nonatomic, copy) UIColor *touchPointColor;

@property (nonatomic) CGFloat touchReferenceLineAlpha;
@property (nonatomic) CGFloat touchReferenceLineWidth;
@property (nonatomic, copy) NSArray *touchReferenceLineDashPattern;
@property (nonatomic, copy) UIColor *touchReferenceLineColor;

@property (nonatomic, copy) UIColor *verticalReferenceLineColor;
@property (nonatomic) CGFloat verticalReferenceLineWidth;
@property (nonatomic) CGFloat verticalReferenceLineAlpha;
@property (nonatomic, copy) NSArray *verticalReferenceLineDashPattern;

@property (nonatomic, copy) UIColor *horizontalRefernenceLineColor;
@property (nonatomic) CGFloat horizontalReferenceLineWidth;
@property (nonatomic) CGFloat horizontalReferenceLineAlpha;
@property (nonatomic, copy) NSArray *horizontalReferenceLineDashPattern;

@property (nonatomic, copy) UIColor *averageLineColor;
@property (nonatomic) CGFloat averageLineWidth;
@property (nonatomic) CGFloat averageLineAlpha;
@property (nonatomic, copy) NSArray *averageLineDashPattern;

@property (nonatomic, strong) UIView *touchView;

///////--------------------------------- Unsettable Property ------------------------------------///////

@property (nonatomic, readonly) WYLineChartCalculator *calculator;

///////--------------------------------------- Methors ------------------------------------------///////

/**
 *	redraw line chart
 */
- (void)updateGraph;

@end
