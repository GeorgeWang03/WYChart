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

@protocol WYRadarChartViewItemDescription <NSObject>

- (NSString *)title;

@end

@protocol WYRadarChartViewDataSource <NSObject>

- (WYRadarChartDimension *)radarChartView:(WYRadarChartView *)radarChartView dimensionAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfItemInRadarChartView:(WYRadarChartView *)radarChartView;

- (id<WYRadarChartViewItemDescription>)radarChartView:(WYRadarChartView *)radarChartView descriptionForItemAtIndex:(NSUInteger)index;

- (NSArray <NSNumber *>*)radarChartView:(WYRadarChartView *)radarChartView valueForItemAtIndex:(NSUInteger)index;

@end

@interface WYRadarChartView : UIView

@property (nonatomic, assign, readonly) NSUInteger dimensionCount;
@property (nonatomic, assign, readonly) NSUInteger gradient;

@property (nonatomic, weak) id<WYRadarChartViewDataSource> dataSource;

- (instancetype)init __attribute__((unavailable("use initWithFrame:dimensionCount:gradient instead")));
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("use initWithFrame:dimensionCount:gradient instead")));

- (instancetype)initWithFrame:(CGRect)frame dimensionCount:(NSUInteger)dimensionCount gradient:(NSUInteger)gradient;

@end
