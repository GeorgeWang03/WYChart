//
//  PieChartViewController.m
//  WYChart
//
//  Created by yingwang on 16/8/22.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "PieChartViewController.h"
#import "WYChartCategory.h"
#import "WYPieChartView.h"
#import "PieChartSettingViewController.h"

@interface PieChartViewController ()<WYPieChartViewDelegate,
                                     WYPieChartViewDatasource>

@property (nonatomic, strong) WYPieChartView *pieView;
@property (nonatomic, strong) PieChartSettingViewController *settingViewController;

@end

@implementation PieChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WYPieChart";
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    // Do any additional setup after loading the view.
    
    _settingViewController = [[PieChartSettingViewController alloc] init];
    
    _pieView = [[WYPieChartView alloc] initWithFrame:CGRectMake(0, 70, self.view.wy_boundsWidth, 300)];
    _pieView.delegate = self;
    _pieView.datasource = self;
    _pieView.backgroundColor = [UIColor clearColor];
    
    
    _pieView.values = @[@50, @200, @40, @300, @100];
    
    [self.view addSubview:_pieView];
    CGFloat boundsWidth = CGRectGetWidth(self.view.bounds);
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - 180, boundsWidth/2-40, 60)];
    button.layer.cornerRadius = 5;
    button.clipsToBounds = true;
    [button setImage:[UIImage imageNamed:@"btn_reload"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithWhite:0.3 alpha:0.1]]
                      forState:UIControlStateNormal];
    [button addTarget:_pieView action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
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
    _pieView.style = [_settingViewController.parameters[kPieChartStyle] unsignedIntegerValue];
    _pieView.selectedStyle = [_settingViewController.parameters[kPieChartSelectedStyle] unsignedIntegerValue];
    _pieView.animationStyle = [_settingViewController.parameters[kPieChartAnimationStyle] unsignedIntegerValue];
    _pieView.animationDuration = roundf([_settingViewController.parameters[kPieChartAnimationDuration] floatValue]);
    _pieView.fillByGradient = [_settingViewController.parameters[kPieChartFillByGradient] boolValue];;
    _pieView.showInnerCircle = [_settingViewController.parameters[kPieChartShowInnerCircle] boolValue];
    _pieView.rotatable = [_settingViewController.parameters[kPieChartRotatable] boolValue];
    [_pieView update];
}

- (void)handleSettingButton {
    
    [self.navigationController pushViewController:_settingViewController
                                         animated:true];
}

#pragma mark - Pie Chart View Delegate
- (NSInteger)numberOfLabelOnPieChartView:(WYPieChartView *)pieChartView {
    
    return 5;
}

#pragma mark - Pie Chart View Datasource

- (NSString *)pieChartView:(WYPieChartView *)pieChartView textForLabelAtIndex:(NSInteger)index {
    
    return @"73.21312%";
}

- (NSInteger)pieChartView:(WYPieChartView *)pieChartView valueIndexReferToLabelAtIndex:(NSInteger)index {
    return index;
}

- (UIColor *)pieChartView:(WYPieChartView *)pieChartView sectorColorAtIndex:(NSInteger)index {
    
    UIColor *color;
    
    switch (index) {
        case 0:
            color = [UIColor wy_colorWithHexString:@"#D65F5F"];
            break;
        case 1:
            color = [UIColor wy_colorWithHexString:@"#FAF99F"];
            break;
        case 2:
            color = [UIColor wy_colorWithHexString:@"#A1F6B6"];
            break;
        case 3:
            color = [UIColor wy_colorWithHexString:@"#78D8D0"];
            break;
        case 4:
            color = [UIColor wy_colorWithHexString:@"#0C4762"];
            break;
        default:
            break;
    }
    return color;
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
