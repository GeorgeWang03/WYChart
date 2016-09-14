//
//  LineChartSettingViewController.m
//  WYChart
//
//  Created by yingwang on 16/8/22.
//  Copyright © 2016年 yingwang. All rights reserved.
//
#import "WYLineChartView.h"
#import "LineChartSettingViewController.h"

NSString const *kLineChartAnimationDuration = @"kLineChartAnimationDuration";
NSString const *kLineChartAnimationStyle = @"kLineChartAnimationStyle";
NSString const *kLineChartScrollable = @"kLineChartScrollable";
NSString const *kLineChartPinchable = @"kLineChartPinchable";
NSString const *kLineChartLineStyle = @"kLineChartLineStyle";
NSString const *kLineChartDrawGradient = @"kLineChartDrawGradient";
NSString const *kLineChartJunctionStyle = @"kLineChartJunctionStyle";
NSString const *kLineChartBackgroundColor = @"kLineChartBackgroundColor";

#define ANIMATION_PICKER_VIEW_TAG 100
#define LINE_STYLE_PICKER_VIEW_TAG 200
#define JUNCTION_STYLE_PICKER_VIEW_TAG 300
#define BACKGROUND_COLOR_PICKER_VIEW_TAG 400

#define COLOR_1TH [UIColor colorWithRed:12.f/255.f green:71.f/255.f blue:98.f/255.f alpha:0.9]
#define COLOR_2ND [UIColor colorWithRed:166.f/255.f green:54.f/255.f blue:54.f/255.f alpha:0.9]
#define COLOR_3RD [UIColor colorWithRed:249.f/255.f green:197.f/255.f blue:53.f/255.f alpha:0.9]

@interface LineChartSettingViewController () <UIPickerViewDelegate,
                                              UIPickerViewDataSource>

@property (nonatomic, strong) UILabel *animationDurationLabel;

@end

@implementation LineChartSettingViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@2.0, kLineChartAnimationDuration,
                       @(kWYLineChartAnimationDrawing), kLineChartAnimationStyle,
                       @(false), kLineChartScrollable,
                       @(true), kLineChartPinchable,
                       @(kWYLineChartMainBezierWaveLine), kLineChartLineStyle,
                       @(true), kLineChartDrawGradient,
                       @(kWYLineChartJunctionShapeSolidCircle), kLineChartJunctionStyle,
                       COLOR_1TH, kLineChartBackgroundColor,
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
    label.text = [NSString stringWithFormat:@"animationDuration : %f", [_parameters[kLineChartAnimationDuration] floatValue]];
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
    slider.value = [_parameters[kLineChartAnimationDuration] floatValue];
    [slider addTarget:self action:@selector(animationDurationDidChange:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:slider];
    
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
    pickView.tag = ANIMATION_PICKER_VIEW_TAG;
//    NSLog(@"pick index = %lu", [_parameters[kLineChartAnimationStyle] unsignedIntegerValue]);
    [pickView selectRow:[_parameters[kLineChartAnimationStyle] unsignedIntegerValue]
            inComponent:0 animated:false];
    [scrollView addSubview:pickView];
    
    y = y+height+5;
    height = 30;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"Scrollable";
    [scrollView addSubview:label];
    
    UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame),
                                                                    y, 150, 30)];
    switcher.tintColor = [UIColor cyanColor];
    [switcher addTarget:self action:@selector(scrollableSwitchDidChange:)
       forControlEvents:UIControlEventValueChanged];
    switcher.on = [_parameters[kLineChartScrollable] boolValue];
    [scrollView addSubview:switcher];
    
    y = y+height+5;
    height = 30;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"Pinchable";
    [scrollView addSubview:label];
    
    switcher = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame),
                                                                    y, 150, 30)];
    switcher.tintColor = [UIColor cyanColor];
    [switcher addTarget:self action:@selector(pinchableSwitchDidChange:)
       forControlEvents:UIControlEventValueChanged];
    switcher.on = [_parameters[kLineChartPinchable] boolValue];
    [scrollView addSubview:switcher];
    
    y = y+height+5;
    height = 20;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"Line Style";
    [scrollView addSubview:label];
    
    x = 20;
    width = boundsWidth - 40;
    y += (10+height);
    height = 200;
    pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    pickView.dataSource = self;
    pickView.delegate = self;
    pickView.tag = LINE_STYLE_PICKER_VIEW_TAG;
//    NSLog(@"pick index = %lu", [_parameters[kLineChartLineStyle] unsignedIntegerValue]);
    [pickView selectRow:[_parameters[kLineChartLineStyle] unsignedIntegerValue]
            inComponent:0 animated:false];
    [scrollView addSubview:pickView];
    
    y = y+height+5;
    height = 30;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"Gradient";
    [scrollView addSubview:label];
    
    switcher = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame),
                                                          y, 150, 30)];
    switcher.tintColor = [UIColor cyanColor];
    [switcher addTarget:self action:@selector(gradientSwitchDidChange:)
       forControlEvents:UIControlEventValueChanged];
    switcher.on = [_parameters[kLineChartDrawGradient] boolValue];
    [scrollView addSubview:switcher];
    
    y = y+height+5;
    height = 20;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"Junction Style";
    [scrollView addSubview:label];
    
    x = 20;
    width = boundsWidth - 40;
    y += (10+height);
    height = 200;
    pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    pickView.dataSource = self;
    pickView.delegate = self;
    pickView.tag = JUNCTION_STYLE_PICKER_VIEW_TAG;
//    NSLog(@"pick index = %lu", [_parameters[kLineChartJunctionStyle] unsignedIntegerValue]);
    [pickView selectRow:[_parameters[kLineChartJunctionStyle] unsignedIntegerValue]
            inComponent:0 animated:false];
    [scrollView addSubview:pickView];
    
    y = y+height+5;
    height = 20;
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, height)];
    label.font = [UIFont systemFontOfSize:12.f];
    label.text = @"BackgroundColor";
    [scrollView addSubview:label];
    
    width = boundsWidth-40;
    x = 20;
    y += (10+height);
    height = 40;
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"DarkBlue",@"Red",@"Yellow"]];
    segmentControl.frame = CGRectMake(x, y, width, height);
    segmentControl.tintColor = [UIColor cyanColor];
    segmentControl.selectedSegmentIndex = 0;
    [segmentControl addTarget:self action:@selector(backgroundColorSegmentDidChange:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:segmentControl];
    
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), y+height+40);
}

- (void)animationDurationDidChange:(UISlider *)sender {
//    NSLog(@"slider = %f", sender.value);
    _parameters[kLineChartAnimationDuration] = @(sender.value);
    _animationDurationLabel.text = [NSString stringWithFormat:@"animationDuration : %f", sender.value];
}

- (void)backgroundColorSegmentDidChange:(UISegmentedControl *)sender {
//    NSLog(@"pie chart style index = %lu", sender.selectedSegmentIndex);
    switch (sender.selectedSegmentIndex) {
        case 0:
            _parameters[kLineChartBackgroundColor] = COLOR_1TH;
            break;
        case 1:
            _parameters[kLineChartBackgroundColor] = COLOR_2ND;
            break;
        case 2:
            _parameters[kLineChartBackgroundColor] = COLOR_3RD;
            break;
        default:
            break;
    }
}

- (void)scrollableSwitchDidChange:(UISwitch *)sender {
//    NSLog(@"rotatable switch = %lu", sender.on);
    _parameters[kLineChartScrollable] = @(sender.on);
}

- (void)pinchableSwitchDidChange:(UISwitch *)sender {
//    NSLog(@"rotatable switch = %lu", sender.on);
    _parameters[kLineChartPinchable] = @(sender.on);
}

- (void)gradientSwitchDidChange:(UISwitch *)sender {
//    NSLog(@"rotatable switch = %lu", sender.on);
    _parameters[kLineChartDrawGradient] = @(sender.on);
}

#pragma mark - pickerView delegate and dataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == ANIMATION_PICKER_VIEW_TAG) {
        return 6;
    }
    if (pickerView.tag == LINE_STYLE_PICKER_VIEW_TAG) {
        return 4;
    }
    if (pickerView.tag == JUNCTION_STYLE_PICKER_VIEW_TAG) {
        return 9;
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 200;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 60;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    if (pickerView.tag == ANIMATION_PICKER_VIEW_TAG) {
        switch (row) {
            case 0:
                title = @"Drawing";
                break;
            case 1:
                title = @"Alpha";
                break;
            case 2:
                title = @"Width";
                break;
            case 3:
                title = @"Rise";
                break;
            case 4:
                title = @"Spring";
                break;
            case 5:
                title = @"None";
                break;
            default:
                break;
        }
    }
    if (pickerView.tag == LINE_STYLE_PICKER_VIEW_TAG) {
        switch (row) {
            case 0:
                title = @"Straight";
                break;
            case 1:
                title = @"Wave";
                break;
            case 2:
                title = @"Taper";
                break;
            case 3:
                title = @"None";
                break;
            default:
                break;
        }
    }
    if (pickerView.tag == JUNCTION_STYLE_PICKER_VIEW_TAG) {
        switch (row) {
            case 0:
                title = @"None";
                break;
            case 1:
                title = @"SolidCircle";
                break;
            case 2:
                title = @"HollowCircle";
                break;
            case 3:
                title = @"SolidSquare";
                break;
            case 4:
                title = @"HollowSquare";
                break;
            case 5:
                title = @"SolidRectangle";
                break;
            case 6:
                title = @"HollowRectangle";
                break;
            case 7:
                title = @"SolidStar";
                break;
            case 8:
                title = @"HollowStar";
                break;
            default:
                break;
        }
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"animation style = %lu", row);
    if (pickerView.tag == ANIMATION_PICKER_VIEW_TAG) {
        _parameters[kLineChartAnimationStyle] = @(row);
    }
    if (pickerView.tag == LINE_STYLE_PICKER_VIEW_TAG) {
        _parameters[kLineChartLineStyle] = @(row);
    }
    if (pickerView.tag == JUNCTION_STYLE_PICKER_VIEW_TAG) {
        _parameters[kLineChartJunctionStyle] = @(row);
    }
    
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
