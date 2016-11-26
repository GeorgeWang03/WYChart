//
//  WYLineChartView.h
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYLineChartDefine.h"
#import "WYLineChartJunctionShape.h"


@interface WYLineChartView : UIView

///////--------------------------------- Settable Property ------------------------------------///////

@property (nonatomic, weak) id<WYLineChartViewDelegate> delegate;
@property (nonatomic, weak) id<WYLineChartViewDatasource> datasource;

// all the points of lines on the graph
// the content should be:
// /* points */@[
//                  /* line 0 */ @[
//                                 /* point 0 */ (WYLineChartPoint *)point0, point1, point2 ...
//                                 ],
//                  /* line 1 */ @[
//                                 /* point 0 */ (WYLineChartPoint *)point0, point1, point2 ...
//                                 ],
//              ]
// v0.2.0
@property (nonatomic, strong) NSArray *points;

// define if the line graph can scroll
// default YES.
@property (nonatomic) BOOL scrollable;

//default NO
@property (nonatomic) BOOL pinchable;

@property (nonatomic) CGFloat lineLeftMargin;
@property (nonatomic) CGFloat lineRightMargin;
@property (nonatomic) CGFloat lineTopMargin;
@property (nonatomic) CGFloat lineBottomMargin;

// including xAxis, yAxis, yAxis prefix and suffix
@property (nonatomic, strong) UIFont *labelsFont;
@property (nonatomic, strong) UIColor *labelsColor;
// point label
@property (nonatomic, strong) UIColor *pointsLabelsColor;
@property (nonatomic, strong) UIColor *pointsLabelsBackgroundColor;

@property (nonatomic, strong) UIColor *axisColor;

@property (nonatomic, strong) NSString *yAxisHeaderPrefix;
@property (nonatomic, strong) NSString *yAxisHeaderSuffix;

@property (nonatomic) WYLineChartAnimationStyle animationStyle;
@property (nonatomic) CGFloat animationDuration;

@property (nonatomic) WYLineChartJunctionShapeStyle touchPointStyle;
@property (nonatomic) WYLineChartJunctionShapeSize touchPointSize;
@property (nonatomic, copy) UIColor *touchPointColor;

// define if the touch point and reference line will show when longpress
// default is YES. When line`s cout more than 1 (also means lineChartView.points.cout > 1) in the graph, it will be set to NO which means touch point and reference line will not show.
@property (nonatomic) BOOL touchable; // v0.2.0
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
