//
//  RadarChartViewController.m
//  WYChart
//
//  Created by Allen on 28/11/2016.
//  Copyright © 2016 FreedomKing. All rights reserved.
//

#import "RadarChartViewController.h"
#import "WYRadarChartView.h"

@interface RadarChartViewController ()
<
WYRadarChartViewDataSource
>

@property (nonatomic, strong) WYRadarChartView *radarChartView;

@end

@implementation RadarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.radarChartView = [[WYRadarChartView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds))
                                                   dimensionCount:5
                                                         gradient:5];
    self.radarChartView.dataSource = self;
    [self.view addSubview:self.radarChartView];
}

#pragma mark - WYRadarChartViewDataSource

- (WYRadarChartDimension *)radarChartView:(WYRadarChartView *)radarChartView dimensionAtIndex:(NSUInteger)index {
    return nil;
}

- (NSUInteger)numberOfItemInRadarChartView:(WYRadarChartView *)radarChartView {
    return 2;
}

- (NSArray<NSNumber *> *)radarChartView:(WYRadarChartView *)radarChartView valueForItemAtIndex:(NSUInteger)index {
    return @[@[@(0.9),@(0.1),@(0.8),@(8.43),@(0.44)],
             @[@(10.29),@(10.71),@(10.28),@(8.43),@(10.144)]][index];
}

- (id<WYRadarChartViewItemDescription>)radarChartView:(WYRadarChartView *)radarChartView descriptionForItemAtIndex:(NSUInteger)index {
    return nil;
}

@end
