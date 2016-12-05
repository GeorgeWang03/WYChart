//
//  RadarChartViewController.m
//  WYChart
//
//  Created by Allen on 28/11/2016.
//  Copyright © 2016 FreedomKing. All rights reserved.
//

#import "RadarChartViewController.h"
#import "WYRadarChartView.h"
#import "WYRadarChartModel.h"
#import <WYChart/WYChartCategory.h>

@interface RadarChartViewController ()
<
WYRadarChartViewDataSource
>

@property (nonatomic, strong) WYRadarChartView *radarChartView;
@property (nonatomic, strong) NSMutableArray <WYRadarChartItem *> *items;

@end

@implementation RadarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
    [self.radarChartView reloadDataWithAnimation:WYRadarChartViewAnimationScale duration:1];
}

- (void)initData {
    self.items = [NSMutableArray new];
    for (NSInteger index = 0; index < 1; index++) {
        WYRadarChartItem *item = [WYRadarChartItem new];
        NSMutableArray *value = [NSMutableArray new];
        for (NSInteger i = 0; i < self.radarChartView.dimensionCount; i++) {
            [value addObject:@(arc4random_uniform(100)*0.01)];
        }
        item.value = value;
        item.borderColor = [UIColor wy_colorWithHex:arc4random_uniform(0xffffff)];
        item.fillColor = [UIColor wy_colorWithHex:arc4random_uniform(0xffffff) alpha:0.5];
        [self.items addObject:item];
    }
}

- (void)setupUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.radarChartView = [[WYRadarChartView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds))
                                                   dimensionCount:5
                                                         gradient:5];
    self.radarChartView.dataSource = self;
    self.radarChartView.lineWidth = 0.5;
    self.radarChartView.lineColor = [UIColor redColor];
    [self.view addSubview:self.radarChartView];
}

#pragma mark - WYRadarChartViewDataSource

- (WYRadarChartDimension *)radarChartView:(WYRadarChartView *)radarChartView dimensionAtIndex:(NSUInteger)index {
    return nil;
}

- (NSUInteger)numberOfItemInRadarChartView:(WYRadarChartView *)radarChartView {
    return self.items.count;
}

- (WYRadarChartItem *)radarChartView:(WYRadarChartView *)radarChartView itemAtIndex:(NSUInteger)index {
    return self.items[index];
}

- (id<WYRadarChartViewItemDescription>)radarChartView:(WYRadarChartView *)radarChartView descriptionForItemAtIndex:(NSUInteger)index {
    return nil;
}

@end
