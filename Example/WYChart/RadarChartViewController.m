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

@interface SliderView : UIView

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UISlider *slider;

@end

@implementation SliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, self.wy_boundsHeight)];
    self.label.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.label];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(self.label.wy_maxX, 0 , self.wy_boundsWidth - 10 - self.label.wy_maxX, self.wy_boundsHeight)];
    self.slider.continuous = NO;
    [self addSubview:self.slider];
}

@end

@interface RadarChartViewController ()
<
WYRadarChartViewDataSource
>

@property (nonatomic, strong) WYRadarChartView *radarChartView;
@property (nonatomic, strong) NSMutableArray <WYRadarChartItem *> *items;
@property (nonatomic, strong) NSMutableArray <WYRadarChartDimension *> *dimensions;

@property (nonatomic, assign) NSInteger dimensionCount;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) NSInteger gradient;
@property (nonatomic, assign) WYRadarChartViewAnimation animation;

@property (nonatomic, strong) SliderView *dimensionCountSliderView;
@property (nonatomic, strong) SliderView *itemCountSliderView;
@property (nonatomic, strong) SliderView *gradientSliderView;
@property (nonatomic, strong) UISegmentedControl *animationSegmentedControl;

@end

@implementation RadarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupData];
    [self setupUI];
    [self.radarChartView reloadDataWithAnimation:self.animation duration:1];
}

- (void)initData {
    self.dimensionCount = 5;
    self.itemCount = 1;
    self.gradient = 1;
    self.animation = WYRadarChartViewAnimationStrokePath;
}

- (void)setupData {
    self.items = [NSMutableArray new];
    for (NSInteger index = 0; index < self.itemCount; index++) {
        WYRadarChartItem *item = [WYRadarChartItem new];
        NSMutableArray *value = [NSMutableArray new];
        for (NSInteger i = 0; i < self.dimensionCount; i++) {
            [value addObject:@(arc4random_uniform(100)*0.01)];
        }
        item.value = value;
        item.borderColor = [UIColor wy_colorWithHex:0xffffff];
        item.fillColor = [UIColor wy_colorWithHex:arc4random_uniform(0xffffff) alpha:0.5];
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
    self.dimensionCountSliderView = [[SliderView alloc] initWithFrame:CGRectMake(0, self.radarChartView.wy_maxY + 10, self.view.wy_boundsWidth, 40)];
    self.dimensionCountSliderView.slider.minimumValue = 3;
    self.dimensionCountSliderView.slider.maximumValue = 10;
    self.dimensionCountSliderView.slider.value = self.dimensionCount;
    self.dimensionCountSliderView.label.text = [NSString stringWithFormat:@"dimension: %@", @(self.dimensionCount)];
    [self.dimensionCountSliderView.slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.dimensionCountSliderView];
    
    self.itemCountSliderView = [[SliderView alloc] initWithFrame:CGRectMake(0, self.dimensionCountSliderView.wy_maxY, self.view.wy_boundsWidth, 40)];
    self.itemCountSliderView.slider.maximumValue = 10;
    self.itemCountSliderView.slider.minimumValue = 0;
    self.itemCountSliderView.slider.value = self.itemCount;
    self.itemCountSliderView.label.text = [NSString stringWithFormat:@"itemCount: %@", @(self.itemCount)];
    [self.itemCountSliderView.slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.itemCountSliderView];
    
    self.gradientSliderView = [[SliderView alloc] initWithFrame:CGRectMake(0, self.itemCountSliderView.wy_maxY, self.view.wy_boundsWidth, 40)];
    self.gradientSliderView.slider.maximumValue = 10;
    self.gradientSliderView.slider.minimumValue = 1;
    self.gradientSliderView.slider.value = self.itemCount;
    self.gradientSliderView.label.text = [NSString stringWithFormat:@"gradient: %@", @(self.itemCount)];
    [self.gradientSliderView.slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.gradientSliderView];
    
    self.animationSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"none", @"scale", @"storkePath"]];
    self.animationSegmentedControl.frame = CGRectMake(0, self.gradientSliderView.wy_maxY, self.view.wy_boundsWidth, 40);
    [self.animationSegmentedControl addTarget:self action:@selector(animationSegmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    self.animationSegmentedControl.selectedSegmentIndex = self.animation;
    [self.view addSubview:self.animationSegmentedControl];
}

- (void)setupRadarView {
    if (self.radarChartView.superview == self.view) {
        [self.radarChartView removeFromSuperview];
    }
    self.radarChartView = [[WYRadarChartView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds))
                                                       dimensions:self.dimensions
                                                         gradient:0];
    self.radarChartView.dataSource = self;
    self.radarChartView.lineWidth = 0.5;
    self.radarChartView.lineColor = [UIColor wy_colorWithHex:0xffffff alpha:0.5];
    self.radarChartView.gradient = self.gradient;
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

- (void)sliderValueDidChange:(UISlider *)slider {
    if (slider == self.dimensionCountSliderView.slider) {
        self.dimensionCount = slider.value;
        self.dimensionCountSliderView.label.text = [NSString stringWithFormat:@"dimension: %@",@(self.dimensionCount)];
        [self setupData];
        [self setupRadarView];
    }
    else if (slider == self.itemCountSliderView.slider) {
        self.itemCount = slider.value;
        self.itemCountSliderView.label.text = [NSString stringWithFormat:@"itemCount :%@", @(self.itemCount)];
        [self setupData];
    }
    else if (slider == self.gradientSliderView.slider) {
        self.gradient = slider.value;
        self.gradientSliderView.label.text = [NSString stringWithFormat:@"gradient :%@", @(self.gradient)];
        self.radarChartView.gradient = self.gradient;
    }

    [self.radarChartView reloadDataWithAnimation:self.animation duration:1];
}

- (void)animationSegmentedControlValueDidChange:(UISegmentedControl *)control {
    self.animation = (WYRadarChartViewAnimation)control.selectedSegmentIndex;
    [self.radarChartView reloadDataWithAnimation:self.animation duration:1.0];
}

@end
