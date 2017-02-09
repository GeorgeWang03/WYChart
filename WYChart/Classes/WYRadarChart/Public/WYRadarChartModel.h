//
//  WYRadarChartModel.h
//  WYChart
//
//  Created by Allen on 25/11/2016.
//  Copyright © 2016年 Allen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYLineChartJunctionShape.h"

@protocol WYRadarChartViewItemDescription <NSObject>

- (NSString *)title;

@end

@interface WYRadarChartItem : NSObject

/*
 *  Values should be between 0 and 1
 */
@property (nonatomic, strong) NSArray<NSNumber *> *value;

/*
 *  fillColor, default 0xffffff alpha: 0.5
 */
@property (nonatomic, strong) UIColor *fillColor;

/*
 *  borderColor, default [UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *borderColor;

/*
 *  borderWidth, default 0.5
 */
@property (nonatomic, assign) CGFloat borderWidth;

/*
 *  default is kWYLineChartJunctionShapeNone
 */
@property (nonatomic, assign) WYLineChartJunctionShapeStyle junctionShape;

@end

@interface WYRadarChartDimension: NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIImage *icon;

/*
 *  如果不指定，则用title的大小
 */
@property (nonatomic, assign) CGSize viewSize;

@end
