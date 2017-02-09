//
//  WYRadarChartView.h
//  WYChart
//
//  Created by Allen on 25/11/2016.
//  Copyright © 2016年 Allen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYRadarChartModel.h"

@class WYRadarChartView;

typedef NS_ENUM(NSUInteger, WYRadarChartViewAnimation) {
    WYRadarChartViewAnimationNone,
    WYRadarChartViewAnimationScale,
    WYRadarChartViewAnimationScaleSpring,
    WYRadarChartViewAnimationStrokePath
};

@protocol WYRadarChartViewDataSource <NSObject>

- (NSUInteger)numberOfItemInRadarChartView:(WYRadarChartView *)radarChartView;

- (id<WYRadarChartViewItemDescription>)radarChartView:(WYRadarChartView *)radarChartView descriptionForItemAtIndex:(NSUInteger)index;

- (WYRadarChartItem *)radarChartView:(WYRadarChartView *)radarChartView itemAtIndex:(NSUInteger)index;

@end

@interface WYRadarChartView : UIView

/*
 *  dimensions of data, which determines the corner amount of the polygon in WYRadarChartView
 *
 *  统计数据的维度，决定了WYRadarChartView中多边形的角的个数
 */
@property (nonatomic, strong, readonly) NSArray <WYRadarChartDimension *>* dimensions;

/*  determines the circle amount, default (at least) is 1, the outermost circle
 *  
 *  数据的变化梯度，决定WYRadarChartView中环形的个数，默认是1，即最外围的环形
 */
@property (nonatomic, assign) NSUInteger gradient;

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, weak) id<WYRadarChartViewDataSource> dataSource;

- (instancetype)init __attribute__((unavailable("use initWithFrame:dimensionCount:gradient instead")));
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("use initWithFrame:dimensionCount:gradient instead")));

- (instancetype)initWithFrame:(CGRect)frame dimensions:(NSArray <WYRadarChartDimension *> *)dimensions;

- (void)reloadData;

- (void)reloadDataWithAnimation:(WYRadarChartViewAnimation)animation duration:(NSTimeInterval)duration;

@end
