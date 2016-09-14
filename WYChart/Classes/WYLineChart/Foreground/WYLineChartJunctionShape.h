//
//  WYLineChartCircle.h
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WYLineChartJunctionShapeStyle) {
    
    kWYLineChartJunctionShapeNone,
    kWYLineChartJunctionShapeSolidCircle,
    kWYLineChartJunctionShapeHollowCircle,
    kWYLineChartJunctionShapeSolidSquare,
    kWYLineChartJunctionShapeHollowSquare,
    kWYLineChartJunctionShapeSolidRectangle,
    kWYLineChartJunctionShapeHollowRectangle,
    kWYLineChartJunctionShapeSolidStar,
    kWYLineChartJunctionShapeHollowStar
};

typedef NS_ENUM(NSUInteger, WYLineChartJunctionShapeSize) {
    kWYLineChartJunctionSmallShape,
    kWYLineChartJunctionMiddleShape,
    kWYLineChartJunctionLargeShape
};

@interface WYLineChartJunctionShape : UIView

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;

- (instancetype)initWithStyle:(WYLineChartJunctionShapeStyle)style size:(WYLineChartJunctionShapeSize)size origin:(CGPoint)origin;


@end
