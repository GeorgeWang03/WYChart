//
//  WYPieChartCalculator.h
//  WYChart
//
//  Created by yingwang on 16/8/13.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYPieChartView.h"

@interface WYPieChartCalculator : NSObject

- (NSArray *)createSectorsForValues:(NSArray *)values atPoint:(CGPoint)point radius:(CGFloat)raduis pieStyle:(WYPieChartStyle)style showInnerCircle:(BOOL)showInnerCircle;
- (NSArray *)createSectorsForValues:(NSArray *)values atPoint:(CGPoint)point radius:(CGFloat)radius maxAngle:(CGFloat)maxAngle pieStyle:(WYPieChartStyle)style showInnerCircle:(BOOL)showInnerCircle;

- (NSArray *)createSectorFromSectors:(NSArray *)sectors maxAngle:(CGFloat)maxAngle;

@end
