//
//  WYLineChartCoordinateView.h
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WYLineChartView;

@interface WYLineChartCoordinateView : UIView

@property (nonatomic, weak) WYLineChartView *parentView;

@end

@interface WYLineChartCoordinateYAXisView : WYLineChartCoordinateView

@end

@interface WYLineChartCoordinateXAXisView : WYLineChartCoordinateView

@end