//
//  WYRadarChartModel.m
//  WYChart
//
//  Created by Allen on 25/11/2016.
//  Copyright © 2016年 Allen. All rights reserved.
//

#import "WYRadarChartModel.h"
#import <WYChart/WYChartCategory.h>

@implementation WYRadarChartItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _fillColor = [UIColor wy_colorWithHex:0xffffff alpha:0.5];
        _borderColor = [UIColor whiteColor];
        _borderWidth = 0.5;
    }
    return self;
}

@end

@implementation WYRadarChartDimension

- (instancetype)init {
    self = [super init];
    if (self) {
        _titleColor = [UIColor whiteColor];
        _titleFont = [UIFont systemFontOfSize:12];
        _viewSize = CGSizeMake(-1, -1);
    }
    return self;
}

@end
