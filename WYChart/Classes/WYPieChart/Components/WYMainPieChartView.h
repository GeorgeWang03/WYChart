//
//  WYMainPieChartView.h
//  WYChart
//
//  Created by yingwang on 16/8/13.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WYPieChartView.h"

@interface WYMainPieChartView : UIView

@property (nonatomic, readonly) CGFloat sectorsRadius;

@property (nonatomic, copy) NSArray *sectors;

@property (nonatomic, weak) WYPieChartView *parentView;

///////--------------------------------------- Animation ------------------------------------------///////

@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) WYPieChartAnimationStyle animationStyle;

@property (nonatomic) WYPieChartStyle style;

///////--------------------------------------- Interact ------------------------------------------///////

@property (nonatomic) BOOL selectable;
@property (nonatomic) BOOL rotatabel;
@property (nonatomic) BOOL draggable;

///////--------------------------------------- Attributes ------------------------------------------///////

@property (nonatomic) BOOL showInnerCircle;

@property (nonatomic, copy) UIColor *strokeColor;

@property (nonatomic) CGFloat lineWidth;

@property (nonatomic) BOOL fillByGradient;

@end
