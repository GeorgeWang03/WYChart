//
//  LineChartSettingViewController.h
//  WYChart
//
//  Created by yingwang on 16/8/22.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSString const *kLineChartAnimationDuration;
FOUNDATION_EXTERN NSString const *kLineChartAnimationStyle;
FOUNDATION_EXTERN NSString const *kLineChartScrollable;
FOUNDATION_EXTERN NSString const *kLineChartPinchable;
FOUNDATION_EXTERN NSString const *kLineChartLineStyle;
FOUNDATION_EXTERN NSString const *kLineChartDrawGradient;
FOUNDATION_EXTERN NSString const *kLineChartJunctionStyle;
FOUNDATION_EXTERN NSString const *kLineChartBackgroundColor;

@interface LineChartSettingViewController : UIViewController

@property (nonatomic) NSMutableDictionary *parameters;

@end
