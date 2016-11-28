//
//  WYRadarChartMainView.m
//  WYChart
//
//  Created by Allen on 25/11/2016.
//  Copyright © 2016年 Allen. All rights reserved.
//

#import "WYRadarChartMainView.h"
#import <math.h>

#define WYRadarChartViewMargin  10

@interface WYRadarChartMainView()

@property (nonatomic, assign) CGFloat dimensionMaxLength;
@property (nonatomic, strong) NSMutableArray<NSValue *> *factors;
@property (nonatomic, assign) CGPoint radarCenter;

@end

@implementation WYRadarChartMainView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.dimensionMaxLength = (CGRectGetWidth(self.bounds) - WYRadarChartViewMargin)*0.5;
    self.radarCenter = self.center;
    double degress = M_PI * 2 / self.dimensionCount;
    self.factors = [NSMutableArray new];
    for (NSInteger index = 0; index < self.dimensionCount; index++) {
        CGPoint temPoint = CGPointMake(cos(degress*index), sin(degress*index));
        [self.factors addObject:[NSValue valueWithCGPoint:temPoint]];
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSInteger index = 1; index <= self.gradient; index++) {
        CGPathRef path = [self ringPathWithDimensionLength:self.dimensionMaxLength*index/self.gradient];
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGPathRelease(path);
    }
}

- (CGPathRef)ringPathWithDimensionLength:(CGFloat)dimensionLength {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.radarCenter.x+dimensionLength, self.radarCenter.y);
    for (NSInteger index = 1; index < self.dimensionCount; index++) {
        CGPoint factor = [[self.factors objectAtIndex:index] CGPointValue];
        CGPoint temPoint = CGPointMake(self.radarCenter.x + dimensionLength*factor.x, self.radarCenter.y + dimensionLength*factor.y);
        CGPathAddLineToPoint(path, NULL, temPoint.x, temPoint.y);
    }
    CGPathAddLineToPoint(path, NULL, self.radarCenter.x+dimensionLength, self.radarCenter.y);
    return path;
}

@end
