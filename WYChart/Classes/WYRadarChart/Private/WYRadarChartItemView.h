//
//  WYRadarShapeLayer.h
//  WYChart
//
//  Created by Allen on 08/01/2017.
//  Copyright © 2017 FreedomKing. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WYRadarChartModel.h"
#import "WYRadarChartView.h"

@interface WYRadarChartItemView : UIView

- (instancetype)initWithFrame:(CGRect)frame item:(WYRadarChartItem *)item;

@property (nonatomic, strong, readonly) WYRadarChartItem *item;
@property (nonatomic, strong, readonly) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) NSArray <NSValue *> *breakPoints;

- (void)startJunctionAnimationWithStyle:(WYRadarChartViewAnimation)animationStyle
                                  delay:(NSTimeInterval)delay
                               duration:(NSTimeInterval)duration;

@end
