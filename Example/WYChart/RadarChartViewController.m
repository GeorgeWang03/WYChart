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

@property (nonatomic, strong) UILabel *dimensionCountLabel;
@property (nonatomic, strong) UISlider *dimensionCountSlider;

@end

@implementation RadarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dimensionCount = 5;
    [self initData];
    [self setupUI];
    [self.radarChartView reloadDataWithAnimation:WYRadarChartViewAnimationScale duration:1];
}

- (void)initData {
    
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
    //  RadarChartView
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupRadarView];
    
    //
    self.dimensionCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.radarChartView.wy_boundsHeight + 10, 100, 50)];
    self.dimensionCountLabel.adjustsFontSizeToFitWidth = YES;
    self.dimensionCountLabel.text = [NSString stringWithFormat:@"dimension: %@", @(self.dimensionCount)];
    [self.view addSubview:self.dimensionCountLabel];
    
    self.dimensionCountSlider = [[UISlider alloc] initWithFrame:CGRectMake(self.dimensionCountLabel.wy_maxX, CGRectGetMaxY(self.radarChartView.frame) + 10, self.view.wy_boundsWidth - 10 - self.dimensionCountLabel.wy_maxX, 50)];
    self.dimensionCountSlider.minimumValue = 3;
    self.dimensionCountSlider.maximumValue = 10;
    self.dimensionCountSlider.value = self.dimensionCount;
    self.dimensionCountSlider.continuous = NO;
    [self.dimensionCountSlider addTarget:self action:@selector(dimensionCountSliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.dimensionCountSlider];

}

- (void)setupRadarView {
    if (self.radarChartView.superview == self.view) {
        [self.radarChartView removeFromSuperview];
    }
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

#pragma mark - Actions

- (void)dimensionCountSliderValueDidChange:(UISlider *)slider {
    self.dimensionCount = slider.value;
    self.dimensionCountLabel.text = [NSString stringWithFormat:@"dimension: %@",@(self.dimensionCount)];
    [self initData];
    [self setupRadarView];
    [self.radarChartView reloadDataWithAnimation:WYRadarChartViewAnimationScale duration:1];
}

@end
