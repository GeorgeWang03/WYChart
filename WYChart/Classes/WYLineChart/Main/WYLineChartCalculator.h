//
//  WYLineChartCalculator.h
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

#import "WYLineChartView.h"
@class WYLineChartPathSegment;

@interface WYLineChartCalculator : NSObject

@property (nonatomic, weak) WYLineChartView *parentView;
//the length of X Axis
@property (nonatomic, readonly) CGFloat drawableAreaWidth;
//the length of Y Axis
@property (nonatomic, readonly) CGFloat drawableAreaHeight;
//the width of label on the Y Axis left side
@property (nonatomic, readonly) CGFloat yAxisLabelWidth;
//the height of label below X Axis
@property (nonatomic, readonly) CGFloat xAxisLabelHeight;
//the height of label below Y Axis
@property (nonatomic, readonly) CGFloat yAxisLabelHeight;
//the width of y axis
@property (nonatomic, readonly) CGFloat yAxisViewWidth;
//the width of line graph window
@property (nonatomic, readonly) CGFloat lineGraphWindowWidth;

/**
 *  return a value for a label at the index
 *
 *	@param index	the index refer to labels on x axis
 *
 *	@return the label width
 */
- (CGFloat)widthOfLabelOnXAxisAtIndex:(NSInteger)index;
/**
 *	return center.x for a point in line graph
 *
 *	@param index	a point index
 *
 *	@return point.center.x
 */
- (CGFloat)xLocationForPointAtIndex:(NSInteger)index;
/**
 *	return center.y for a point in line graph
 *
 *	@param index	a point index
 *
 *	@return point.center.y
 */
- (CGFloat)yLocationForPointAtIndex:(NSInteger)index;
/**
 *	recalculate coordinate for points when graph redraw or points updated
 ＊ 重新计算所有点在坐标轴中的位置
 */
- (void)recaclculatePointsCoordinate;
/**
 *  update all path segment for points, including quadratic formula (the coefficent A,B,C), control point
 *  @return Array with element of WYLineChartPathSegment
 */
- (NSArray *)recalculatePathSegmentsForPoints:(NSArray *)points withLineStyle:(WYLineChartMainLineStyle)lineStyle;

- (WYLineChartPoint *)maxValueOfPoints:(NSArray *)points;

- (WYLineChartPathSegment *)segmentForPoint:(CGPoint)point inSegments:(NSArray *)segments;

///////--------------------------------------- About Bezier Path ------------------------------------------///////

/**
 *	return a new mpoint, which mpoint.x = (p1.x + p2.x)/2 and mpoint.y = (p1.y + p2.y)/2
 *  计算中点
 */
- (CGPoint)middlePointBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2;
/**
 *	return a control point which y is equal to the lower point between p1 and p2
 *  返回的控制点y坐标等于p1和p2中y值更小的
 */
- (CGPoint)lowerControlPointBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2;
/**
 *	return a control point which y is equal to the higher point between p1 and p2
 *  返回的控制点y坐标等于p1和p2中y值更大的
 */
- (CGPoint)higherControlPointBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2;

///////--------------------------------------- About Values ------------------------------------------///////

/**
 *  calculate average for WYLineChartPoints value
 *  计算给出的WYLineChartPoints类型的点的value平均值
 */
- (CGFloat)calculateAverageForPoints:(NSArray *)points;
/**
 *	return the y for average value on line graph
 *  返回所给出平均值在线图中的竖直方向位置
 */
- (CGFloat)verticalLocationForValue:(CGFloat)average;

- (CGFloat)valueReferToVerticalLocation:(CGFloat)location;

@end
