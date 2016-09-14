//
//  WYPieSector.m
//  WYChart
//
//  Created by yingwang on 16/8/15.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYPieSector.h"

@implementation WYPieSector

- (id)copyWithZone:(NSZone *)zone {
    
    WYPieSector *sector = [[WYPieSector alloc] init];
    sector.value = self.value;
    sector.startAngle = self.startAngle;
    sector.angle = self.angle;
    sector.endAngle = self.endAngle;
    sector.radius = self.radius;
    sector.vertex = self.vertex;
    sector.color = self.color;
    sector.innerRadius = self.innerRadius;
    sector.outerRadius = self.outerRadius;
    sector.fillByGradient = self.fillByGradient;
    
    return sector;
}

- (CGPoint)center {
    
    CGPoint center;
    CGFloat centerAngle = (_startAngle + _endAngle) / 2;
    CGFloat y = sin(centerAngle)*_radius/2;
    CGFloat x = cos(centerAngle)*_radius/2;
    center = CGPointMake(_vertex.x + x, _vertex.y + y);
    return center;
}

- (CGPoint)contactPoint {
    
    CGPoint contact;
    CGFloat centerAngle = (_startAngle + _endAngle) / 2;
    CGFloat y = sin(centerAngle)*_radius;
    CGFloat x = cos(centerAngle)*_radius;
    contact = CGPointMake(_vertex.x + x, _vertex.y + y);
    return contact;
}

- (CGFloat)centerAngle {
    
    CGFloat centerAngle = (_startAngle + _endAngle) / 2;
    return centerAngle;
}

- (CGFloat)heightOfArcOutsideWithRotateAngle:(CGFloat)angle {
    CGFloat startAngleHeight;
    CGFloat endAngleHeight;
    CGFloat height;
    
    startAngleHeight = sinf(_startAngle+angle)*_radius;
    endAngleHeight = sinf(_endAngle+angle)*_radius;
    height = fabs(startAngleHeight - endAngleHeight);
    return height;
}

@end
