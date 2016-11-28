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

@protocol WYRadarChartViewDataSource <NSObject>

- (NSInteger)numberOfDimensionInRadarChartView:(WYRadarChartView *)radarChartView;
- (WYRadarChartDimension *)radarChartView:(WYRadarChartView *)radarChartView dimensionAtIndex:(NSInteger)index;

@end

@interface WYRadarChartView : UIView

//@property (nonatomic, strong) NSArray<> *data;

- (instancetype)initWithFrame:(CGRect)frame;

@end
