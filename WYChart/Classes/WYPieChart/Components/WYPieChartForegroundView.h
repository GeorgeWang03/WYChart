//
//  WYPieChartForegroundView.h
//  WYChart
//
//  Created by yingwang on 16/8/22.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WYPieChartView;

@interface WYPieChartForegroundView : UIView

@property (nonatomic, weak) WYPieChartView *parentView;

@property (nonatomic) NSArray *sectors;

@property (nonatomic, strong) UIColor *labelsTextColor;
@property (nonatomic, strong) UIColor *labelsBackgroundColor;

- (void)reloadData;

- (void)updateWithRotateAngle:(CGFloat)angle;

@end
