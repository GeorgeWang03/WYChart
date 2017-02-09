//
//  WYRadarChartMainView.h
//  WYChart
//
//  Created by Allen on 25/11/2016.
//  Copyright © 2016年 Allen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYRadarChartView.h"

@interface WYRadarChartMainView : UIView

@property (nonatomic, assign) NSUInteger gradient;
@property (nonatomic, weak) id<WYRadarChartViewDataSource> dataSource;
@property (nonatomic, weak) WYRadarChartView *radarChartView;

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) NSArray *dimensions;

- (instancetype)initWithFrame:(CGRect)frame dimensions:(NSArray<WYRadarChartDimension *> *)dimensions gradient:(NSUInteger)gradient;

- (void)reloadDataWithAnimation:(WYRadarChartViewAnimation)animation duration:(NSTimeInterval)duration;

@end
