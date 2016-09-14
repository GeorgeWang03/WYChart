//
//  WYPieSector.h
//  WYChart
//
//  Created by yingwang on 16/8/15.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYPieSector : NSObject <NSCopying>

@property (nonatomic) CGFloat value;
@property (nonatomic) CGFloat angle;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat innerRadius;
@property (nonatomic) CGFloat outerRadius;

@property (nonatomic) CGPoint vertex;

@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) CGFloat centerAngle;
@property (nonatomic, readonly) CGPoint contactPoint;


@property (nonatomic, copy) UIColor *color;
@property (nonatomic) BOOL fillByGradient;

- (CGFloat)heightOfArcOutsideWithRotateAngle:(CGFloat)angle;

@end
