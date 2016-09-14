//
//  PieChartSettingViewController.h
//  WYChart
//
//  Created by yingwang on 16/8/22.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSString const *kPieChartAnimationDuration;
FOUNDATION_EXTERN NSString const *kPieChartStyle;
FOUNDATION_EXTERN NSString const *kPieChartAnimationStyle;
FOUNDATION_EXTERN NSString const *kPieChartSelectedStyle;
FOUNDATION_EXTERN NSString const *kPieChartRotatable;
FOUNDATION_EXTERN NSString const *kPieChartShowInnerCircle;
FOUNDATION_EXTERN NSString const *kPieChartFillByGradient;

@interface PieChartSettingViewController : UIViewController

@property (nonatomic) NSMutableDictionary *parameters;

@end
