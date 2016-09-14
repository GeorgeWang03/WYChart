//
//  PieChartSettingViewController.m
//  WYChart
//
//  Created by yingwang on 16/8/22.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "PieChartSettingViewController.h"
#import "WYPieChartView.h"

NSString const *kPieChartAnimationDuration = @"kPieChartAnimationDuration";
NSString const *kPieChartStyle = @"kPieChartStyle";
NSString const *kPieChartAnimationStyle = @"kPieChartAnimationStyle";
NSString const *kPieChartSelectedStyle = @"kPieChartSelectedStyle";
NSString const *kPieChartRotatable = @"kPieChartRotatable";
NSString const *kPieChartShowInnerCircle = @"kPieChartShowInnerCircle";
NSString const *kPieChartFillByGradient = @"kPieChartFillByGradient";

@interface PieChartSettingViewController () <UIPickerViewDelegate,
                                            UIPickerViewDataSource>

@property (nonatomic, strong) UILabel *animationDurationLabel;

@end

@implementation PieChartSettingViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@2.0, kPieChartAnimationDuration,
                                                                        @(kWYPieChartNormalStyle), kPieChartStyle,
                                                                        @(kWYPieChartAnimationAllSpreading), kPieChartAnimationStyle,
                                                                        @(true), kPieChartRotatable,
                                                                        @(kWYPieChartSectorSelectedExtraction), kPieChartSelectedStyle,
                                                                        @(true), kPieChartShowInnerCircle,
                                                                        @(false), kPieChartFillByGradient,
                                                                        nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-60)];
    [self.view addSubview:scrollView];
    
    UILabel *label;
    CGFloat x, y, width, height;
    CGFloat boundsWidth = CGRectGetWidth(self.view.bounds);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    CGFloat boudnsHeight = CGRectGetHeight(self.view.bounds);
#pragma clang diagnostic pop
    x = 0;
    y = 0;
    width = 0;
    height = 0;
    
    height = 20;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y+height+5, 170, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = [NSString stringWithFormat:@"animationDuration : %f", [_parameters[kPieChartAnimationDuration] floatValue]];
    [scrollView addSubview:label];
    _animationDurationLabel = label;
    
    width = boundsWidth-40;
    x = 20;
    y = y+height+25;
    height = 40;
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, width, height)];
    slider.minimumValue = 1.0;
    slider.maximumValue = 3.0;
    slider.minimumTrackTintColor = [UIColor cyanColor];
    slider.value = [_parameters[kPieChartAnimationDuration] floatValue];
    [slider addTarget:self action:@selector(animationDurationDidChange:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:slider];
    
    y = y+height+5;
    height = 20;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"Pie Chart Style";
    [scrollView addSubview:label];
    
    width = boundsWidth-40;
    x = 20;
    y += (10+height);
    height = 40;
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Normal",@"Gear"]];
    segmentControl.frame = CGRectMake(x, y, width, height);
    segmentControl.tintColor = [UIColor cyanColor];
    segmentControl.selectedSegmentIndex = [_parameters[kPieChartStyle] unsignedIntegerValue];
    [segmentControl addTarget:self action:@selector(pieChartStyleSegmentDidChange:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:segmentControl];
    
    y = y+height+5;
    height = 20;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"Animation Style";
    [scrollView addSubview:label];
    
    x = 20;
    width = boundsWidth - 40;
    y += (10+height);
    height = 200;
    UIPickerView *pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    pickView.dataSource = self;
    pickView.delegate = self;
//    NSLog(@"pick index = %lu", [_parameters[kPieChartAnimationStyle] unsignedIntegerValue]);
    [pickView selectRow:[_parameters[kPieChartAnimationStyle] unsignedIntegerValue]
            inComponent:0 animated:false];
    [scrollView addSubview:pickView];
    
    y = y+height+5;
    height = 30;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"Rotatable";
    [scrollView addSubview:label];
    
    UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame),
                                                                    y, 150, 30)];
    switcher.tintColor = [UIColor cyanColor];
    [switcher addTarget:self action:@selector(rotatableSwitchDidChange:)
       forControlEvents:UIControlEventValueChanged];
    switcher.on = [_parameters[kPieChartRotatable] boolValue];
    [scrollView addSubview:switcher];
    
    y = y+height+5;
    height = 20;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 150, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"Pie Chart Selected Style";
    [scrollView addSubview:label];
    
    width = boundsWidth-40;
    x = 20;
    y += (10+height);
    height = 40;
    segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Extract",@"Pull", @"None"]];
    segmentControl.frame = CGRectMake(x, y, width, height);
    segmentControl.tintColor = [UIColor cyanColor];
    segmentControl.selectedSegmentIndex = [_parameters[kPieChartSelectedStyle] unsignedIntegerValue];
    [segmentControl addTarget:self action:@selector(pieSelectedChartStyleSegmentDidChange:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:segmentControl];
    
    y = y+height+5;
    height = 30;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"ShowInnerCircle";
    [scrollView addSubview:label];
    
    switcher = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame),
                                                                    y, 150, 30)];
    switcher.tintColor = [UIColor cyanColor];
    [switcher addTarget:self action:@selector(innerCircleSwitchDidChange:)
       forControlEvents:UIControlEventValueChanged];
    switcher.on = [_parameters[kPieChartShowInnerCircle] boolValue];
    [scrollView addSubview:switcher];
    
    y = y+height+5;
    height = 30;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"FillByGradient";
    [scrollView addSubview:label];
    
    switcher = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame),
                                                          y, 150, 30)];
    switcher.tintColor = [UIColor cyanColor];
    [switcher addTarget:self action:@selector(gradientSwitchDidChange:)
       forControlEvents:UIControlEventValueChanged];
    switcher.on = [_parameters[kPieChartFillByGradient] boolValue];
    [scrollView addSubview:switcher];
    
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), y+height+40);
}

- (void)animationDurationDidChange:(UISlider *)sender {
//    NSLog(@"slider = %f", sender.value);
    _parameters[kPieChartAnimationDuration] = @(sender.value);
    _animationDurationLabel.text = [NSString stringWithFormat:@"animationDuration : %f", sender.value];
}



- (void)pieChartStyleSegmentDidChange:(UISegmentedControl *)sender {
//    NSLog(@"pie chart style index = %lu", sender.selectedSegmentIndex);
    _parameters[kPieChartStyle] = @(sender.selectedSegmentIndex);
}
- (void)pieSelectedChartStyleSegmentDidChange:(UISegmentedControl *)sender {
//    NSLog(@"pie chart style index = %lu", sender.selectedSegmentIndex);
    _parameters[kPieChartSelectedStyle] = @(sender.selectedSegmentIndex);
}

- (void)rotatableSwitchDidChange:(UISwitch *)sender {
//    NSLog(@"rotatable switch = %lu", sender.on);
    _parameters[kPieChartRotatable] = @(sender.on);
}

- (void)innerCircleSwitchDidChange:(UISwitch *)sender {
//    NSLog(@"inner circle switch = %lu", sender.on);
    _parameters[kPieChartShowInnerCircle] = @(sender.on);
}

- (void)gradientSwitchDidChange:(UISwitch *)sender {
//    NSLog(@"inner circle switch = %lu", sender.on);
    _parameters[kPieChartFillByGradient] = @(sender.on);
}

#pragma mark - pickerView delegate and dataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 6;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 200;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 60;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    switch (row) {
        case 0:
            title = @"OrderlySpreading";
            break;
        case 1:
            title = @"AllSpreading";
            break;
        case 2:
            title = @"Stretching";
            break;
        case 3:
            title = @"Alpha";
            break;
        case 4:
            title = @"Scale";
            break;
        case 5:
            title = @"None";
            break;
        default:
            break;
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    NSLog(@"animation style = %lu", row);
    _parameters[kPieChartAnimationStyle] = @(row);
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
