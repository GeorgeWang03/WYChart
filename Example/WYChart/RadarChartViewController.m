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
    self.radarChartView = [[WYRadarChartView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds))];
    [self.view addSubview:self.radarChartView];
}

#pragma mark - WYRadarChartViewDataSource

- (NSInteger)numberOfDimensionInRadarChartView:(WYRadarChartView *)radarChartView {
    return 5;
}

- (WYRadarChartDimension *)radarChartView:(WYRadarChartView *)radarChartView dimensionAtIndex:(NSInteger)index {
    return nil;
}

@end
