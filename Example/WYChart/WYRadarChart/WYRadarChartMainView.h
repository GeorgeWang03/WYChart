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

@property (nonatomic, assign) NSUInteger dimensionCount;
@property (nonatomic, assign) NSUInteger gradient;
@property (nonatomic, weak) id<WYRadarChartViewDataSource> dataSource;
@property (nonatomic, weak) WYRadarChartView *radarChartView;

- (instancetype)initWithFrame:(CGRect)frame;

@end
