//
//  WYPieChartCalculator.m
//  WYChart
//
//  Created by yingwang on 16/8/13.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYPieChartCalculator.h"
#import "WYPieSector.h"

#define DEFAULT_MAX_GEAR_DEPTH_RATIO 0.6
#define DEFAULT_MIN_GEAR_DEPTH_RATIO 0.3
#define DEFAULT_INNER_RADIUS_RATIO 0.33

@implementation WYPieChartCalculator

static NSArray * radiusForGearSector(NSArray *values, CGFloat ratio) {
    
    NSMutableArray *radius = [NSMutableArray arrayWithArray:values];
    NSMutableArray *array = [NSMutableArray arrayWithArray:values];
    
    for (NSInteger i = 0; i < array.count; ++i) {
        NSInteger count = 0;
        for (NSInteger j = 0; j < array.count; ++j) {
            if ([array[i] floatValue] < [array[j] floatValue]) {
                ++ count;
            }
        }
        
        [radius replaceObjectAtIndex:i withObject:@((array.count-count)*ratio/array.count)];
    }
    
    return radius;
}

- (NSArray *)createSectorsForValues:(NSArray *)values atPoint:(CGPoint)point radius:(CGFloat)radius pieStyle:(WYPieChartStyle)style showInnerCircle:(BOOL)showInnerCircle {
    
    return [self createSectorsForValues:values atPoint:point radius:radius maxAngle:3*M_PI/2 pieStyle:style showInnerCircle:showInnerCircle];
}

- (NSArray *)createSectorsForValues:(NSArray *)values atPoint:(CGPoint)point radius:(CGFloat)radius maxAngle:(CGFloat)maxAngle pieStyle:(WYPieChartStyle)style showInnerCircle:(BOOL)showInnerCircle {
    
    __block CGFloat currentAngle;
    NSMutableArray *sectors;
    __block CGFloat valueSum;
    __block WYPieSector *currentSector;
    __block CGFloat sectorAngle;
    CGFloat innerRadius;
    
    innerRadius = radius * DEFAULT_INNER_RADIUS_RATIO;
    valueSum = 0;
    currentAngle = -M_PI_2;
    sectors = [NSMutableArray arrayWithCapacity:values.count];
    NSArray *gearRadius = radiusForGearSector(values, showInnerCircle?DEFAULT_MIN_GEAR_DEPTH_RATIO:DEFAULT_MAX_GEAR_DEPTH_RATIO);
    
    [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        valueSum += [obj floatValue];
    }];
    [values enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sectorAngle = [obj floatValue] / valueSum * (maxAngle + M_PI_2);
        currentSector = [[WYPieSector alloc] init];
        currentSector.startAngle = currentAngle;
        currentSector.endAngle = currentAngle + sectorAngle;
        currentSector.angle = sectorAngle;
        currentSector.vertex = point;
        currentSector.value = [obj floatValue];
        currentSector.outerRadius = radius;
        currentSector.innerRadius = showInnerCircle ? radius*DEFAULT_INNER_RADIUS_RATIO : 0;
        
        if (style == kWYPieChartGearStyle) {
            if (showInnerCircle) {
                currentSector.radius = (1 - DEFAULT_MIN_GEAR_DEPTH_RATIO + [gearRadius[idx] floatValue]) * radius;
            } else {
                currentSector.radius = (1 - DEFAULT_MAX_GEAR_DEPTH_RATIO + [gearRadius[idx] floatValue]) * radius * (1 - DEFAULT_INNER_RADIUS_RATIO)
                                       + DEFAULT_INNER_RADIUS_RATIO*radius;
            }
        } else {
            currentSector.radius = radius;
        }
        
        [sectors addObject:currentSector];
        
        currentAngle = currentSector.endAngle;
    }];
    
    return [NSArray arrayWithArray:sectors];
}

- (NSArray *)createSectorFromSectors:(NSArray *)sectors maxAngle:(CGFloat)maxAngle {
    
    NSMutableArray *newSectors;
    newSectors = [NSMutableArray array];
    
    WYPieSector *sector, *newSector;
    for (int idx = 0; idx < sectors.count; ++idx) {
        sector = sectors[idx];
        if (sector.startAngle >= maxAngle) break;
        if (sector.endAngle > maxAngle) {
            newSector = [sector copy];
            newSector.endAngle = maxAngle;
            newSector.angle = newSector.endAngle - newSector.startAngle;
            [newSectors addObject:newSector];
        } else {
            [newSectors addObject:sector];
        }
    }
    
    return newSectors;
}

@end
