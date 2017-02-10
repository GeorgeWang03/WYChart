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
#import "WYLineChartCalculator.h"

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
    
    _chartView.touchPointColor = [UIColor redColor];
    
    _chartView.yAxisHeaderPrefix = @"消费总数";
    _chartView.yAxisHeaderSuffix = @"日期";
    
    _chartView.labelsFont = [UIFont systemFontOfSize:13];
    
    _chartView.verticalReferenceLineColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    _chartView.horizontalRefernenceLineColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    _chartView.axisColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    _chartView.labelsColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    
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
    _chartView.backgroundColor = par[kLineChartBackgroundColor];
    
    _chartView.scrollable = [par[kLineChartScrollable] boolValue];
    _chartView.pinchable = [par[kLineChartPinchable] boolValue];
    
    [self updateGraph];
}

- (void)handleSettingButton {
    
    [self.navigationController pushViewController:_settingViewController
                                         animated:true];
}

- (void)updateGraph {
    
    NSArray *(^ProducePointsA)() = ^() {
        NSMutableArray *mutableArray = [NSMutableArray array];
        NSArray *points = [WYLineChartPoint pointsFromValueArray:@[@(70706.89),@(40446.85),@(50555.67),@(20216.48),@(60664.45),@(80890.34),@(30321.2)]];
        [mutableArray addObject:points];
        points = [WYLineChartPoint pointsFromValueArray:@[@(50503.134)]];
//        [mutableArray addObject:points];
        return mutableArray;
    };
    
    NSArray *(^ProducePointsB)() = ^() {
        NSMutableArray *mutableArray = [NSMutableArray array];
        NSArray *points = [WYLineChartPoint pointsFromValueArray:@[@(70706.89),@(75623.4),@(90980.f),@(80890.34),@(60321.2)]];
        [mutableArray addObject:points];
        points = [WYLineChartPoint pointsFromValueArray:@[@(50503.134),@(50446.85),@(50555.67),@(60216.48),@(50664.45),@(80890.34),@(30321.2)]];
        [mutableArray addObject:points];
        points = [WYLineChartPoint pointsFromValueArray:@[@(30706.89),@(40446.85),@(40555.67),@(20216.48),@(30664.45),@(20890.34),@(20321.2)]];
        [mutableArray addObject:points];
        return mutableArray;
    };
    
    static BOOL isPointsA = false;
    _points = !isPointsA ? ProducePointsA() : ProducePointsB();
    isPointsA = !isPointsA;
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
    
    return [_points[0] count];
}

- (NSInteger)numberOfLabelOnYAxisInLineChartView:(WYLineChartView *)chartView {
    return 3;
}

- (CGFloat)gapBetweenPointsHorizontalInLineChartView:(WYLineChartView *)chartView {
    
    return 60.f;
}

- (NSInteger)numberOfReferenceLineVerticalInLineChartView:(WYLineChartView *)chartView {
    return [_points[0] count];
}

- (NSInteger)numberOfReferenceLineHorizontalInLineChartView:(WYLineChartView *)chartView {
    return 3;
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

- (NSString *)lineChartView:(WYLineChartView *)chartView contextTextForPointAtIndexPath:(NSIndexPath *)indexPath {
    
    if((indexPath.row%3 != 0 && indexPath.section%2 != 0)
       || (indexPath.row%3 == 0 && indexPath.section%2 == 0)) return nil;
    
    NSArray *pointsArray = _chartView.points[indexPath.section];
    WYLineChartPoint *point = pointsArray[indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%lu", (NSInteger)point.value];
    return text;
}

- (NSString *)lineChartView:(WYLineChartView *)chartView contentTextForXAxisLabelAtIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%lu月", index+1];
}

- (WYLineChartPoint *)lineChartView:(WYLineChartView *)chartView pointReferToXAxisLabelAtIndex:(NSInteger)index {
    return _points[0][index];
}

- (WYLineChartPoint *)lineChartView:(WYLineChartView *)chartView pointReferToVerticalReferenceLineAtIndex:(NSInteger)index {
    
    return _points[0][index];
}

- (NSString *)lineChartView:(WYLineChartView *)chartView contentTextForYAxisLabelAtIndex:(NSInteger)index {
    
    CGFloat value;
    switch (index) {
        case 0:
            value = [self.chartView.calculator minValuePointsOfLinesPointSet:self.chartView.points].value;
            break;
        case 1:
            value = [self.chartView.calculator maxValuePointsOfLinesPointSet:self.chartView.points].value;
            break;
        case 2:
            value = [self.chartView.calculator calculateAverageForPointsSet:self.chartView.points];
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"%lu", (NSInteger)value];
}

- (CGFloat)lineChartView:(WYLineChartView *)chartView valueReferToYAxisLabelAtIndex:(NSInteger)index {
    
    CGFloat value;
    switch (index) {
        case 0:
            value = [self.chartView.calculator minValuePointsOfLinesPointSet:self.chartView.points].value;
            break;
        case 1:
            value = [self.chartView.calculator maxValuePointsOfLinesPointSet:self.chartView.points].value;
            break;
        case 2:
            value = [self.chartView.calculator calculateAverageForPointsSet:self.chartView.points];
            break;
        default:
            break;
    }
    return value;
}

- (CGFloat)lineChartView:(WYLineChartView *)chartView valueReferToHorizontalReferenceLineAtIndex:(NSInteger)index {
    
    CGFloat value;
    switch (index) {
        case 0:
            value = [self.chartView.calculator minValuePointsOfLinesPointSet:self.chartView.points].value;
            break;
        case 1:
            value = [self.chartView.calculator maxValuePointsOfLinesPointSet:self.chartView.points].value;
            break;
        case 2:
            value = [self.chartView.calculator calculateAverageForPointsSet:self.chartView.points];
            break;
        default:
            break;
    }
    return value;
}

- (NSDictionary *)lineChartView:(WYLineChartView *)chartView attributesForLineAtIndex:(NSUInteger)index {
    NSDictionary *attribute = [_settingViewController getLineAttributesAtIndex:index];
    NSMutableDictionary *resultAttributes = [NSMutableDictionary dictionary];
    resultAttributes[kWYLineChartLineAttributeLineStyle] = attribute[kLineChartLineStyle];
    resultAttributes[kWYLineChartLineAttributeDrawGradient] = attribute[kLineChartDrawGradient];
    resultAttributes[kWYLineChartLineAttributeJunctionStyle] = attribute[kLineChartJunctionStyle];
    
    UIColor *lineColor;
    switch (index%3) {
        case 0:
            lineColor = [UIColor colorWithRed:165.f/255.f green:203.f/255.f blue:211.f/255.f alpha:0.9];
            break;
        case 1:
            lineColor = [UIColor colorWithRed:250.f/255.f green:134.f/255.f blue:94.f/255.f alpha:0.9];
            break;
        case 2:
            lineColor = [UIColor colorWithRed:242.f/255.f green:188.f/255.f blue:13.f/255.f alpha:0.9];
            break;
        default:
            break;
    }
    
    resultAttributes[kWYLineChartLineAttributeLineColor] = lineColor;
    resultAttributes[kWYLineChartLineAttributeJunctionColor] = lineColor;
    
    return resultAttributes;
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
