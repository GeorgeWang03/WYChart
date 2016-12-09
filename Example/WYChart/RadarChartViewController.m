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
@property (nonatomic, strong) NSMutableArray <WYRadarChartDimension *> *dimensions;

@property (nonatomic, assign) NSInteger dimensionCount;

@end

@implementation RadarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupUI];
    [self.radarChartView reloadDataWithAnimation:WYRadarChartViewAnimationScale duration:1];
}

- (void)initData {
    self.dimensionCount = 5;
    
    self.items = [NSMutableArray new];
    for (NSInteger index = 0; index < 1; index++) {
        WYRadarChartItem *item = [WYRadarChartItem new];
        NSMutableArray *value = [NSMutableArray new];
        for (NSInteger i = 0; i < self.dimensionCount; i++) {
            [value addObject:@(arc4random_uniform(100)*0.01)];
        }
        item.value = value;
        item.borderColor = [UIColor wy_colorWithHex:0xffffff];
        item.fillColor = [UIColor wy_colorWithHex:0xffffff alpha:0.5];
        [self.items addObject:item];
    }
    
    self.dimensions = [NSMutableArray new];
    for (NSInteger index = 0; index < self.dimensionCount; index++) {
        WYRadarChartDimension *dimension = [WYRadarChartDimension new];
        dimension.title = @"title";
        dimension.titleColor = [UIColor whiteColor];
        [self.dimensions addObject:dimension];
    }
}

- (void)setupUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.radarChartView = [[WYRadarChartView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds))
                                                   dimensionCount:self.dimensionCount
                                                         gradient:0];
    self.radarChartView.dataSource = self;
    self.radarChartView.lineWidth = 0.5;
    self.radarChartView.lineColor = [UIColor wy_colorWithHex:0xffffff alpha:0.5];
    self.radarChartView.dimensions = self.dimensions;
    self.radarChartView.backgroundColor = [UIColor wy_colorWithHex:0x245971];
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
