//
//  LineChartViewController.m
//  WYChart
//
//  Created by yingwang on 16/8/22.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYLineChartView.h"
#import "WYLineChartPoint.h"
#import "LineChartViewController.h"
#import "WYChartCategory.h"
#import "LineChartSettingViewController.h"

@interface LineChartViewController () <WYLineChartViewDelegate,
                                       WYLineChartViewDatasource>

@property (nonatomic, strong) WYLineChartView *chartView;
@property (nonatomic, strong) NSArray *points;

@property (nonatomic, strong) UILabel *touchLabel;

@property (nonatomic, strong) LineChartSettingViewController *settingViewController;

@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;

@end

@implementation LineChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WYLineChart";
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _settingViewController = [[LineChartSettingViewController alloc] init];
    
    _chartView = [[WYLineChartView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 300)];
    _chartView.delegate = self;
    _chartView.datasource = self;
    _chartView.points = [NSArray arrayWithArray:_points];
    _chartView.gradientColors = @[[UIColor colorWithWhite:1.0 alpha:0.9],
                                  [UIColor colorWithWhite:1.0 alpha:0.0]];
    _chartView.gradientColorsLocation = @[@(0.0), @(0.95)];
    
    
    _chartView.touchPointColor = [UIColor redColor];
    
    _chartView.yAxisHeaderPrefix = @"消费总数";
    _chartView.yAxisHeaderSuffix = @"日期";
    
    //    _chartView.lineLeftMargin = 100;
    //    _chartView.lineRightMargin = 100;
    
    _touchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _touchLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    _touchLabel.textColor = [UIColor blackColor];
    _touchLabel.layer.cornerRadius = 5;
    _touchLabel.layer.masksToBounds = YES;
    _touchLabel.textAlignment = NSTextAlignmentCenter;
    _touchLabel.font = [UIFont systemFontOfSize:13.f];
    _chartView.touchView = _touchLabel;
    
    [self.view addSubview:_chartView];
    
    CGFloat boundsWidth = CGRectGetWidth(self.view.bounds);
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - 180, boundsWidth/2-40, 60)];
    button.layer.cornerRadius = 5;
    button.clipsToBounds = true;
    [button setImage:[UIImage imageNamed:@"btn_reload"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithWhite:0.3 alpha:0.1]]
                             forState:UIControlStateNormal];
    [button addTarget:self action:@selector(updateGraph) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(boundsWidth/2+20, CGRectGetHeight(self.view.bounds) - 180, boundsWidth/2-40, 60)];
    settingButton.layer.cornerRadius = 5;
    settingButton.clipsToBounds = true;
    [settingButton setImage:[UIImage imageNamed:@"btn_setting"] forState:UIControlStateNormal];
    [settingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [settingButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithWhite:0.3 alpha:0.1]]
                      forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(handleSettingButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingButton];
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSDictionary *par = _settingViewController.parameters;
    _chartView.animationDuration = roundf([par[kLineChartAnimationDuration] floatValue]);
    _chartView.animationStyle = [par[kLineChartAnimationStyle] unsignedIntegerValue];
    _chartView.junctionStyle = [par[kLineChartJunctionStyle] unsignedIntegerValue];
    _chartView.lineStyle = [par[kLineChartLineStyle] unsignedIntegerValue];
    _chartView.backgroundColor = par[kLineChartBackgroundColor];
    
    _chartView.drawGradient = [par[kLineChartDrawGradient] boolValue];
//    _chartView.scrollable = [par[kLineChartScrollable] boolValue];
    _chartView.pinchable = [par[kLineChartPinchable] boolValue];
    
    
    [self updateGraph];
}

- (void)handleSettingButton {
    
    [self.navigationController pushViewController:_settingViewController
                                         animated:true];
}

- (void)updateGraph {
    
    NSArray *(^ProducePointsA)() = ^() {
        NSMutableArray *points = [NSMutableArray arrayWithCapacity:7];
        for (NSInteger idx = 0; idx < 7; ++idx) {
            WYLineChartPoint *point = [[WYLineChartPoint alloc] init];
            point.index = idx;
            [points addObject:point];
        }
        WYLineChartPoint *point = points[0];
        point = points[0];
        point.value = 70706.89;
        point = points[1];
        point.value = 40446.85;
        point = points[2];
        point.value = 50555.67;
        point = points[3];
        point.value = 20216.48;
        point = points[4];
        point.value = 60664.45;
        point = points[5];
        point.value = 80890.34;
        point = points[6];
        point.value = 30321.2;
        return points;
    };
    
    NSArray *(^ProducePointsB)() = ^() {
        NSMutableArray *points = [NSMutableArray arrayWithCapacity:5];
        for (NSInteger idx = 0; idx < 5; ++idx) {
            WYLineChartPoint *point = [[WYLineChartPoint alloc] init];
            point.index = idx;
            [points addObject:point];
        }
        WYLineChartPoint *point = points[0];
        point.value = 50503.134;
        point = points[1];
        point.value = 60623.4;
        point = points[2];
        point.value = 90980.f;
        point = points[3];
        point.value = 80890.34;
        point = points[4];
        point.value = 30321.2;
        return points;
    };
    
    static BOOL isPointsA = false;
    _points = isPointsA ? ProducePointsA() : ProducePointsB();
    isPointsA = !isPointsA;
    
    _maxValue = -MAXFLOAT;
    _minValue = MAXFLOAT;
    [_points enumerateObjectsUsingBlock:^(WYLineChartPoint *point, NSUInteger idx, BOOL * _Nonnull stop) {
        if (point.value > _maxValue) {
            _maxValue = point.value;
        }
        if (point.value < _minValue) {
            _minValue = point.value;
        }
    }];
    _chartView.points = [NSArray arrayWithArray:_points];
    
    [_chartView updateGraph];
}

- (void)handleGesture {
    
//    NSLog(@"touch !");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)findMaxValueInArray

#pragma mark - WYLineChartViewDelegate

- (NSInteger)numberOfLabelOnXAxisInLineChartView:(WYLineChartView *)chartView {
    
    return _points.count;
}

- (CGFloat)gapBetweenPointsHorizontalInLineChartView:(WYLineChartView *)chartView {
    
    return 60.f;
}

- (CGFloat)maxValueForPointsInLineChartView:(WYLineChartView *)chartView {
    
    
    return _maxValue;
}

- (CGFloat)minValueForPointsInLineChartView:(WYLineChartView *)chartView {
    
    return _minValue;
}

- (NSInteger)numberOfReferenceLineVerticalInLineChartView:(WYLineChartView *)chartView {
    return _points.count;
}

- (NSInteger)numberOfReferenceLineHorizontalInLineChartView:(WYLineChartView *)chartView {
    return _points.count;
}

- (void)lineChartView:(WYLineChartView *)lineView didBeganTouchAtSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value {
//    NSLog(@"began move for value : %f", value);
    _touchLabel.text = [NSString stringWithFormat:@"%f", value];
}

- (void)lineChartView:(WYLineChartView *)lineView didMovedTouchToSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value {
//    NSLog(@"changed move for value : %f", value);
    _touchLabel.text = [NSString stringWithFormat:@"%f", value];
}

- (void)lineChartView:(WYLineChartView *)lineView didEndedTouchToSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value {
//    NSLog(@"ended move for value : %f", value);
    _touchLabel.text = [NSString stringWithFormat:@"%f", value];
}

- (void)lineChartView:(WYLineChartView *)lineView didBeganPinchWithScale:(CGFloat)scale {
    
//    NSLog(@"begin pinch, scale : %f", scale);
}

- (void)lineChartView:(WYLineChartView *)lineView didChangedPinchWithScale:(CGFloat)scale {
    
//    NSLog(@"change pinch, scale : %f", scale);
}

- (void)lineChartView:(WYLineChartView *)lineView didEndedPinchGraphWithOption:(WYLineChartViewScaleOption)option scale:(CGFloat)scale {
    
//    NSLog(@"end pinch, scale : %f", scale);
}

#pragma mark - WYLineChartViewDatasource

- (NSString *)lineChartView:(WYLineChartView *)chartView contentTextForXAxisLabelAtIndex:(NSInteger)index {
    return @"8月13日";
}

- (WYLineChartPoint *)lineChartView:(WYLineChartView *)chartView pointReferToXAxisLabelAtIndex:(NSInteger)index {
    return _points[index];
}

- (WYLineChartPoint *)lineChartView:(WYLineChartView *)chartView pointReferToVerticalReferenceLineAtIndex:(NSInteger)index {
    
    return _points[index];
}


- (CGFloat)lineChartView:(WYLineChartView *)chartView valueReferToHorizontalReferenceLineAtIndex:(NSInteger)index {
    
    return ((WYLineChartPoint *)_points[index]).value;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
