//
//  WYRadarChartView.m
//  WYChart
//
//  Created by Allen on 25/11/2016.
//  Copyright © 2016年 Allen. All rights reserved.
//

#import "WYRadarChartView.h"
#import "WYRadarChartMainView.h"
#import <math.h>

@interface WYRadarChartView()

@property (nonatomic, strong) WYRadarChartMainView *radarMainView;

@property (nonatomic, strong) NSArray <WYRadarChartDimension *>* dimensions;

@end

@implementation WYRadarChartView

- (instancetype)initWithFrame:(CGRect)frame dimensions:(NSArray<WYRadarChartDimension *> *)dimensions {
    self = [super initWithFrame:frame];
    if (self) {
        _dimensions = dimensions;
        _gradient = 1;
        [self setup];
    }
    return self;
}

- (void)setup {
    self.radarMainView = [[WYRadarChartMainView alloc] initWithFrame:self.bounds dimensions:self.dimensions gradient:self.gradient];
    [self addSubview:self.radarMainView];
}

#pragma mark - getter and setter

- (void)setDataSource:(id<WYRadarChartViewDataSource>)dataSource {
    _dataSource = dataSource;
    self.radarMainView.dataSource = dataSource;
    self.radarMainView.radarChartView = self;
    [self.radarMainView setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    self.radarMainView.lineWidth = lineWidth;
    [self reloadData];
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    self.radarMainView.lineColor = lineColor;
    [self reloadData];
}

- (void)setGradient:(NSUInteger)gradient {
    gradient = (gradient < 1 ? 1 : gradient);
    _gradient = gradient;
    self.radarMainView.gradient = gradient;
    [self reloadData];
}

#pragma mark - data

- (void)reloadData {
    [self.radarMainView reloadDataWithAnimation:WYRadarChartViewAnimationNone duration:0.0];
}

- (void)reloadDataWithAnimation:(WYRadarChartViewAnimation)animation duration:(NSTimeInterval)duration {
    [self.radarMainView reloadDataWithAnimation:animation duration:duration];
}

@end
