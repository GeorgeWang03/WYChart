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
#import "WYRadarChartDimensionView.h"

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

- (instancetype)initWithFrame:(CGRect)frame dimensionCount:(NSUInteger)dimensionCount gradient:(NSUInteger)gradient {
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(dimensionCount >= 3, @"dimensionCount must be at least 3");
        _dimensionCount = dimensionCount;
        _gradient = gradient < 1 ? 1 : gradient;
        _hadDisplay = NO;
        _animationStyle = WYRadarChartViewAnimationNone;
        _animationDuration = 0.0;
        _lineWidth = 0.5;
        _lineColor = [UIColor whiteColor];
        [self initData];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
}

- (void)initData {
    self.dimensionMaxLength = (CGRectGetWidth(self.bounds) - WYRadarChartViewMargin)*0.3;
    self.radarCenter = self.center;
    double degress = M_PI * 2 / self.dimensionCount;
    self.factors = [NSMutableArray new];
    for (NSInteger index = 0; index < self.dimensionCount; index++) {
        CGPoint temPoint = CGPointMake(cos(degress*index - M_PI_2), sin(degress*index - M_PI_2));
        [self.factors addObject:[NSValue valueWithCGPoint:temPoint]];
    }
}

#pragma mark - UI drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw ring
    for (NSInteger index = 1; index <= self.gradient; index++) {
        CGPathRef path = [self ringPathWithRatios:[NSArray arrayByRepeatObject:@((CGFloat)index/self.gradient) time:self.dimensionCount]];
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGPathRelease(path);
    }
    
    // draw line
    CGMutablePathRef path = CGPathCreateMutable();
    for (NSValue *f in self.factors) {
        CGPoint factor = [f CGPointValue];
        CGPathMoveToPoint(path, NULL, self.radarCenter.x, self.radarCenter.y);
        CGPathAddLineToPoint(path, NULL, self.radarCenter.x + self.dimensionMaxLength * factor.x, self.radarCenter.y + self.dimensionMaxLength * factor.y);
    }
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
    
    [self setupSublayer];
    [self setupDimensions];
    self.hadDisplay = YES;
}

- (CGPathRef)ringPathWithRatios:(NSArray <NSNumber *>*) ratios {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint initialFactor = [self.factors[0] CGPointValue];
    CGPoint initialPoint = CGPointMake(self.radarCenter.x + self.dimensionMaxLength * [ratios[0] floatValue] * initialFactor.x,
                                       self.radarCenter.y + self.dimensionMaxLength * [ratios[0] floatValue] * initialFactor.y);
    CGPathMoveToPoint(path, NULL, initialPoint.x, initialPoint.y);
    for (NSInteger index = 1; index < self.dimensionCount; index++) {
        CGFloat length = self.dimensionMaxLength * [ratios[index] floatValue];
        CGPoint factor = [[self.factors objectAtIndex:index] CGPointValue];
        CGPoint temPoint = CGPointMake(self.radarCenter.x + length*factor.x, self.radarCenter.y + length*factor.y);
        CGPathAddLineToPoint(path, NULL, temPoint.x, temPoint.y);
    }
    CGPathAddLineToPoint(path, NULL, initialPoint.x, initialPoint.y);
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

- (void)setupDimensions {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger index = 0; index < self.dimensionCount && index < self.dimensions.count; index++) {
        WYRadarChartDimensionView *dimensionView = [[WYRadarChartDimensionView alloc] initWithDimension:self.dimensions[index]];
        CGPoint factor = [self.factors[index] CGPointValue];
        CGFloat length = self.dimensionMaxLength + sqrt(CGRectGetHeight(dimensionView.bounds)*CGRectGetHeight(dimensionView.bounds)*0.25 + CGRectGetWidth(dimensionView.bounds)*CGRectGetWidth(dimensionView.bounds)*0.25);
        dimensionView.center = CGPointMake(self.radarCenter.x+length*factor.x, self.radarCenter.y+length*factor.y);
        [self addSubview:dimensionView];
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
