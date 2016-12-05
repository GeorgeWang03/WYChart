//
//  WYRadarChartMainView.m
//  WYChart
//
//  Created by Allen on 25/11/2016.
//  Copyright © 2016年 Allen. All rights reserved.
//

#import "WYRadarChartMainView.h"
#import <math.h>
#import "NSArray+Utils.h"
#import "YYWeakProxy.h"

#define WYRadarChartViewMargin  10

@interface WYRadarChartMainView()

@property (nonatomic, assign) CGFloat dimensionMaxLength;
@property (nonatomic, strong) NSMutableArray<NSValue *> *factors;
@property (nonatomic, assign) CGPoint radarCenter;

@property (nonatomic, assign) BOOL hadDisplay;
@property (nonatomic, assign) WYRadarChartViewAnimation animationStyle;
@property (nonatomic, assign) NSTimeInterval animationDuration;

@end

@implementation WYRadarChartMainView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        _hadDisplay = NO;
        _animationStyle = WYRadarChartViewAnimationNone;
        _animationDuration = 0.0;
        _lineWidth = 0.5;
        _lineColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor grayColor];
    self.transform = CGAffineTransformRotate(self.transform, -M_PI_2);
}

#pragma mark - UI drawing

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
        CGPathRef path = [self ringPathWithRatios:[NSArray arrayByRepeatObject:@((CGFloat)index/self.gradient) time:self.dimensionCount]];
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGPathRelease(path);
    }
    [self setupSublayer];
    self.hadDisplay = YES;
}

- (CGPathRef)ringPathWithRatios:(NSArray <NSNumber *>*) ratios {
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat initialLength = self.dimensionMaxLength * [ratios[0] floatValue];
    CGPathMoveToPoint(path, NULL, self.radarCenter.x+initialLength, self.radarCenter.y);
    for (NSInteger index = 1; index < self.dimensionCount; index++) {
        CGFloat length = self.dimensionMaxLength * [ratios[index] floatValue];
        CGPoint factor = [[self.factors objectAtIndex:index] CGPointValue];
        CGPoint temPoint = CGPointMake(self.radarCenter.x + length*factor.x, self.radarCenter.y + length*factor.y);
        CGPathAddLineToPoint(path, NULL, temPoint.x, temPoint.y);
    }
    CGPathAddLineToPoint(path, NULL, self.radarCenter.x+initialLength, self.radarCenter.y);
    return path;
}

- (void)setupSublayer {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    NSUInteger itemCount = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemInRadarChartView:)]) {
        itemCount = [self.dataSource numberOfItemInRadarChartView:self.radarChartView];
    }
    if (itemCount == 0) {
        return;
    }
    
    for (NSInteger index = 0; index < itemCount; index++) {
        NSMutableArray *values = nil;
        WYRadarChartItem *item = nil;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(radarChartView:itemAtIndex:)]) {
            item = [self.dataSource radarChartView:self.radarChartView itemAtIndex:index];
            values = [item.value mutableCopy];
        }
        if (!values || values.count < self.dimensionCount) {
            NSAssert(false, @"require %@ values, but only get %@", @(self.dimensionCount), @(values.count));
            return;
        }
        for (NSInteger i = 0; i < values.count; i++) {
            if ([values[i] floatValue] > 1) {
                values[i] = @(1.0);
                continue;
            }
            if ([values[i] floatValue] < 0) {
                values[i] = @(0.0);
            }
            
        }
        CGPathRef path = [self ringPathWithRatios:values];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = path;
        layer.lineWidth = item.borderWidth;
        layer.fillColor = item.fillColor.CGColor;
        layer.strokeColor = item.borderColor.CGColor;
        layer.frame = self.bounds;
        [self.layer addSublayer:layer];
        CGPathRelease(path);
    }
}

#pragma mark - Animation

- (void)reloadDataWithAnimation:(WYRadarChartViewAnimation)animation duration:(NSTimeInterval)duration {
    self.animationStyle = animation;
    self.animationDuration = duration;
    if (animation == WYRadarChartViewAnimationNone) {
        [self setNeedsDisplay];
        return;
    }
    
    self.hadDisplay = NO;
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self setNeedsDisplay];
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(displayLinkAction:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)doAnimation {
    switch (self.animationStyle) {
        case WYRadarChartViewAnimationScale: {
            for (CAShapeLayer *layer in self.layer.sublayers) {
                CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
                animation.values = @[@(0.0),@(1.0)];
                animation.duration = self.animationDuration;
                [layer addAnimation:animation forKey:@"ScaleAnimation"];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)displayLinkAction:(CADisplayLink *)displayLink {
    if (self.hadDisplay) {
        [self doAnimation];
        [displayLink invalidate];
    }
}

@end
