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
#import "WYRadarChartItemView.h"
#import "UIView+WYAnimation.h"

#define WYRadarChartViewMargin              10
#define WYRadarChartViewAnimationItemKey   @"WYRadarChartViewAnimationItemKey"

@interface WYRadarChartMainView()
<
CAAnimationDelegate
>

@property (nonatomic, assign) CGFloat dimensionMaxLength;
@property (nonatomic, strong) NSMutableArray<NSValue *> *factors;
@property (nonatomic, assign) CGPoint radarCenter;

@property (nonatomic, assign) WYRadarChartViewAnimation animationStyle;
@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, strong) NSMutableArray <WYRadarChartItemView *> *itemViews;
@property (nonatomic, strong) NSMutableArray <WYRadarChartDimensionView *> *dimensionViews;
@property (nonatomic, assign) NSUInteger dimensionCount;

@end

@implementation WYRadarChartMainView

- (instancetype)initWithFrame:(CGRect)frame dimensions:(NSArray<WYRadarChartDimension *> *)dimensions gradient:(NSUInteger)gradient {
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(dimensions.count >= 3, @"dimensionCount must be at least 3");
        _dimensionCount = dimensions.count;
        _dimensions = dimensions;
        _gradient = gradient < 1 ? 1 : gradient;
        _animationStyle = WYRadarChartViewAnimationNone;
        _animationDuration = 0.0;
        _lineWidth = 0.5;
        _lineColor = [UIColor whiteColor];
        [self initData];
        [self setupUI];
        [self setupItemViews];
        [self setupDimensions];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
}

- (void)initData {
    self.dimensionMaxLength = (CGRectGetWidth(self.bounds) - WYRadarChartViewMargin)*0.3;
    self.radarCenter = self.center;
    double degress = M_PI * 2 / self.dimensions.count;
    self.factors = [NSMutableArray new];
    for (NSInteger index = 0; index < self.dimensionCount; index++) {
        CGPoint temPoint = CGPointMake(cos(degress*index - M_PI_2), sin(degress*index - M_PI_2));
        [self.factors addObject:[NSValue valueWithCGPoint:temPoint]];
    }
    self.itemViews = [NSMutableArray new];
    self.dimensionViews = [NSMutableArray new];
}

#pragma mark - UI drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw ring
    for (NSInteger index = 1; index <= self.gradient; index++) {
        NSArray *breakPoints = [self breakPointWithRatios:[NSArray arrayByRepeatObject:@((CGFloat)index/self.gradient) time:self.dimensionCount]];
        CGPathRef path = [[self class] ringPathWithBreakPoint:breakPoints];
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
}

- (NSArray <NSValue *> *)breakPointWithRatios:(NSArray <NSNumber *>*) ratios {
    NSMutableArray *breakPoints = [NSMutableArray new];
    CGPoint initialFactor = [self.factors[0] CGPointValue];
    CGPoint initialPoint = CGPointMake(self.radarCenter.x + self.dimensionMaxLength * [ratios[0] floatValue] * initialFactor.x,
                                       self.radarCenter.y + self.dimensionMaxLength * [ratios[0] floatValue] * initialFactor.y);
    [breakPoints addObject:[NSValue valueWithCGPoint:initialPoint]];
    for (NSInteger index = 1; index < self.dimensionCount; index++) {
        CGFloat length = self.dimensionMaxLength * [ratios[index] floatValue];
        CGPoint factor = [[self.factors objectAtIndex:index] CGPointValue];
        CGPoint temPoint = CGPointMake(self.radarCenter.x + length*factor.x, self.radarCenter.y + length*factor.y);
        [breakPoints addObject:[NSValue valueWithCGPoint:temPoint]];
    }
    return breakPoints;
}

+ (CGPathRef)ringPathWithBreakPoint:(NSArray <NSValue *> *)breakPoint {
    if (breakPoint.count <= 0) {
        return NULL;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint initialPoint = [breakPoint[0] CGPointValue];
    CGPathMoveToPoint(path, NULL, initialPoint.x, initialPoint.y);
    for (NSInteger index = 1; index < breakPoint.count; index++) {
        CGPoint currentPoint = [breakPoint[index] CGPointValue];
        CGPathAddLineToPoint(path, NULL, currentPoint.x, currentPoint.y);
    }
    CGPathAddLineToPoint(path, NULL, initialPoint.x, initialPoint.y);
    return path;
}

- (void)setupItemViews {
    [self.itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.itemViews removeAllObjects];
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
        NSArray <NSValue *> *breakPoints = [self breakPointWithRatios:values];
        CGPathRef path = [[self class] ringPathWithBreakPoint:breakPoints];
        WYRadarChartItemView *itemView = [[WYRadarChartItemView alloc] initWithFrame:self.bounds item:item];
        itemView.shapeLayer.path = path;
        itemView.breakPoints = breakPoints;
        [self addSubview:itemView];
        [self.itemViews addObject:itemView];
        CGPathRelease(path);
    }
}

- (void)setupDimensions {
    [self.dimensionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.dimensionViews removeAllObjects];
    for (NSInteger index = 0; index < self.dimensionCount && index < self.dimensions.count; index++) {
        WYRadarChartDimensionView *dimensionView = [[WYRadarChartDimensionView alloc] initWithDimension:self.dimensions[index]];
        CGPoint factor = [self.factors[index] CGPointValue];
        CGFloat length = self.dimensionMaxLength + sqrt(CGRectGetHeight(dimensionView.bounds)*CGRectGetHeight(dimensionView.bounds)*0.25 + CGRectGetWidth(dimensionView.bounds)*CGRectGetWidth(dimensionView.bounds)*0.25);
        dimensionView.center = CGPointMake(self.radarCenter.x+length*factor.x, self.radarCenter.y+length*factor.y);
        [self.dimensionViews addObject:dimensionView];
        [self addSubview:dimensionView];
    }
}

#pragma mark - Animation

- (void)reloadDataWithAnimation:(WYRadarChartViewAnimation)animation duration:(NSTimeInterval)duration {
    self.animationStyle = animation;
    self.animationDuration = duration;
    [self setNeedsDisplay];
    
    [self setupItemViews];
    [self setupDimensions];
    [self doAnimation];
}

- (void)doAnimation {
    switch (self.animationStyle) {
        case WYRadarChartViewAnimationNone: {
            break;
        }
        case WYRadarChartViewAnimationScale: {
            for (WYRadarChartItemView *itemView in self.itemViews) {
                CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
                animation.values = @[@(0.0),@(1.0)];
                animation.duration = self.animationDuration;
                [itemView.layer addAnimation:animation forKey:@"ScaleAnimation"];
                [itemView startJunctionAnimationWithStyle:self.animationStyle delay:self.animationDuration duration:self.animationDuration];
            }
            
            break;
        }
        case WYRadarChartViewAnimationScaleSpring: {
            for (WYRadarChartItemView *itemView  in self.itemViews) {
                itemView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                [itemView  startJunctionAnimationWithStyle:self.animationStyle
                                                     delay:self.animationDuration*0.5
                                                  duration:self.animationDuration];
                [UIView animateWithDuration:self.animationDuration
                                      delay:0
                     usingSpringWithDamping:0.5
                      initialSpringVelocity:50
                                    options:0
                                 animations:^{
                                     itemView.transform = CGAffineTransformIdentity;
                                 }
                                 completion:nil];
            }

            break;
        }
        case WYRadarChartViewAnimationStrokePath: {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.fromValue = @(0.0);
            animation.toValue = @(1.0);
            animation.duration = self.animationDuration;
            
            for (WYRadarChartItemView *itemView in self.itemViews) {
                [itemView  startJunctionAnimationWithStyle:self.animationStyle
                                                     delay:0
                                                  duration:self.animationDuration];
                itemView.shapeLayer.fillColor = [UIColor clearColor].CGColor;
                [animation setValue:itemView forKey:WYRadarChartViewAnimationItemKey];
                animation.delegate = self;
                [itemView.shapeLayer addAnimation:animation forKey:@"StrokeEndAnimation"];
            }
            break;
        }
        default:
            break;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    switch (self.animationStyle) {
        case WYRadarChartViewAnimationNone: {
            break;
        }
        case WYRadarChartViewAnimationScale: {
            break;
        }
        case WYRadarChartViewAnimationStrokePath: {
            WYRadarChartItemView *itemView = [anim valueForKey:WYRadarChartViewAnimationItemKey];
            itemView.shapeLayer.fillColor = itemView.item.fillColor.CGColor;
            break;
        }
        default:
            break;
    }
}

@end
