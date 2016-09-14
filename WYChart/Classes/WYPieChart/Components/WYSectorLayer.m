//
//  WYSectorLayer.m
//  WYChart
//
//  Created by yingwang on 16/8/16.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYSectorLayer.h"
#import "WYPieSector.h"
#import "WYChartCategory.h"

@interface WYSectorLayer ()

@property (nonatomic, strong) WYPieSector *sector;

@property (nonatomic, weak) id animationDelegate;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) CALayer *controlLayer;

@end

@implementation WYSectorLayer

+ (instancetype)layerWithSectorInfo:(WYPieSector *)sector {
    
    WYSectorLayer *layer = [self layer];
    
    if (layer) {
        layer.sector = sector;
        layer.masksToBounds = true;
        [layer setNeedsDisplay];
    }
    
    return layer;
}



- (void)drawInContext:(CGContextRef)ctx {
    
    if (_sector.fillByGradient) {
//        self.fillColor = [UIColor clearColor].CGColor;
        size_t gradientNum = 2;
        CGFloat gradientLocation[2] = {0.0, 1.0};
        
        const CGFloat *colors = CGColorGetComponents(_sector.color.CGColor);
        CGFloat gradientColor[8] = {colors[0], colors[1], colors[2], 1.0,
            colors[0], colors[1], colors[2], 0.7};
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradientColor, gradientLocation, gradientNum);
        
        CGPoint center = CGPointMake(_sector.radius, _sector.radius);
        CGContextDrawRadialGradient(ctx, gradient, center, 0, center, _sector.radius, kCGGradientDrawsAfterEndLocation);
    } else {
        
        CGContextSetFillColorWithColor(ctx, _sector.color.CGColor);
        CGContextFillRect(ctx, self.bounds);
//        self.fillColor = _sector.color.CGColor;
    }
    
    if (_animationStyle == kWYPieChartAnimationOrderlySpreading) {
        
    }
}

- (void)stopAllAnimations {
    [self removeAllAnimations];
    [self.mask removeAllAnimations];
    [_displayLink invalidate];
    [_controlLayer removeAllAnimations];
}

- (void)addAlphaAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay toValue:(CGFloat)toValue delegate:(id)delegate {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = duration;
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.fromValue = @0.0;
    animation.toValue = @(toValue);
    animation.delegate = delegate;
    [animation setValue:self forKey:@"opacity"];
    [self addAnimation:animation forKey:@"opacity"];
}

- (void)addStretchAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay delegate:(id)delegate {
    
    CALayer *controlLayer = [CALayer layer];
    controlLayer.frame = CGRectMake(0, 0, 10, 10);
    controlLayer.position = CGPointMake(_sector.innerRadius, 0);
    controlLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self addSublayer:controlLayer];
    
    CASpringAnimation *animation = [CASpringAnimation animationWithKeyPath:@"position.x"];
    animation.duration = duration;
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.delegate = self;
    animation.mass = 1;
    animation.stiffness = 200;
    animation.damping = 4;
    animation.initialVelocity = 0;
    animation.fromValue = @(_sector.innerRadius);
    animation.toValue = @(_sector.radius);
    
    [controlLayer addAnimation:animation forKey:@"stretch"];
    
    _controlLayer = controlLayer;
    _animationDelegate = delegate;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(stretchAnimationReload)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)addScaleAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay delegate:(id)delegate {
    
    CALayer *controlLayer = [CALayer layer];
    controlLayer.frame = CGRectMake(_sector.center.x, _sector.center.y, 30, 30);
    controlLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self addSublayer:controlLayer];
//    controlLayer.affineTransform
    
    CASpringAnimation *animation = [CASpringAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration;
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.delegate = self;
    animation.mass = 1;
    animation.stiffness = 200;
    animation.damping = 4;
    animation.initialVelocity = 0;
    [animation setValue:self forKey:@"scale"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    
    [controlLayer addAnimation:animation forKey:@"transform"];
    _controlLayer = controlLayer;
    _animationDelegate = delegate;
    
//    self.anchorPoint = CGPointMake(1.0, 1.0);
//    [self addAnimation:animation forKey:@"scale"];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scaleAnimationReload)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)addDraggingSpringAnimationWithAmplitude:(CGFloat)amplitude delay:(CGFloat)delay delegate:(id)delegate {
    
//    [self removeAllAnimations];
//    [self.mask removeAllAnimations];
    [_controlLayer removeAnimationForKey:@"draggingSpring"];
    
    CALayer *controlLayer = [CALayer layer];
    controlLayer.frame = CGRectMake(0, 0, 5, 5);
    controlLayer.position = CGPointZero;
    controlLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self addSublayer:controlLayer];
    
    CASpringAnimation *animation = [CASpringAnimation animationWithKeyPath:@"position.x"];
    animation.fromValue = @(amplitude);
    animation.toValue = @(0);
    animation.damping = 14;
    animation.mass = 1.5;
    animation.stiffness = 1000;
    animation.duration = animation.settlingDuration;
    animation.delegate = self;
    [animation setValue:controlLayer forKey:@"draggingSpring"];
    
    _animationDelegate = delegate;
    _controlLayer = controlLayer;
    [controlLayer addAnimation:animation forKey:@"draggingSpring"];
    
    if (_displayLink) {
        [_displayLink invalidate];
    }
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(draggingReload)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)draggingReload {
    
    CGFloat radius = _sector.radius + ((CALayer *)_controlLayer.presentationLayer).position.x;
//    NSLog(@"radius = %f", radius);
//    NSLog(@"angle = %f", _sector.angle);
    UIBezierPath *path = [self sectorPathWithVertex:_sector.vertex
                                             radius:radius
                                        innerRadius:_sector.innerRadius
                                         startAngle:_sector.startAngle
                                           endAngle:_sector.endAngle];
    ((CAShapeLayer *)self.mask).path = path.CGPath;
}

- (void)stretchAnimationReload {
    
    CGFloat radius;
    CGPoint controlPosition;
    
    controlPosition = [_controlLayer wy_centerForPresentationLayer:true];
    radius = controlPosition.x;
//    NSLog(@"idx = %f, radius = %f", _sector.startAngle, radius);
    UIBezierPath *path = [self sectorPathWithVertex:_sector.vertex
                                             radius:radius
                                        innerRadius:_sector.innerRadius
                                         startAngle:_sector.startAngle
                                           endAngle:_sector.endAngle];
    CAShapeLayer *mask = (CAShapeLayer *)self.mask;
    mask.path = path.CGPath;
}

- (void)scaleAnimationReload {
    
    CGFloat radius;
    CGFloat scale;
    CGPoint vertex;
    
    scale = [_controlLayer wy_transformScaleForPresentationLayer:true];
    radius = scale*_sector.radius;
//    NSLog(@"scale = %f", scale);
    
    vertex.x = _sector.vertex.x + cosf(_sector.centerAngle)*(1-scale)*_sector.radius/2;
    vertex.y = _sector.vertex.y + sinf(_sector.centerAngle)*(1-scale)*_sector.radius/2;
    
    UIBezierPath *path = [self pathForSector:_sector radius:radius vertex:vertex];
    CAShapeLayer *mask = (CAShapeLayer *)self.mask;
    mask.path = path.CGPath;
}

#pragma mark - animation deleagete

- (void)animationDidStart:(CAAnimation *)anim {
    
    if ([_animationDelegate respondsToSelector:@selector(animationDidStart:)]) {
        [_animationDelegate animationDidStart:anim];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (flag) {
        UIBezierPath *path = [self pathForSector:_sector radius:_sector.radius vertex:_sector.vertex];
        CAShapeLayer *mask = (CAShapeLayer *)self.mask;
        mask.path = path.CGPath;
    }
    
    [[self sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_displayLink invalidate];
    
    if ([_animationDelegate respondsToSelector:@selector(animationDidStop:finished:)]) {
        [_animationDelegate animationDidStop:anim finished:flag];
    }
}

#pragma mark - Shape Creating Methor

- (UIBezierPath *)pathForSector:(WYPieSector *)sector radius:(CGFloat)radius vertex:(CGPoint)vertex {

    return [self sectorPathWithVertex:vertex
                               radius:radius
                          innerRadius:sector.innerRadius*radius/sector.radius
                           startAngle:sector.startAngle endAngle:sector.endAngle];
}

- (UIBezierPath *)sectorPathWithVertex:(CGPoint)vertex
                                radius:(CGFloat)radius
                           innerRadius:(CGFloat)innerRadius
                            startAngle:(CGFloat)startAngle
                              endAngle:(CGFloat)endAngle {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:vertex];
    
    [path addArcWithCenter:vertex
                    radius:radius
                startAngle:startAngle
                  endAngle:endAngle
                 clockwise:true];
    if (innerRadius > 0) {
        [path addArcWithCenter:vertex
                        radius:innerRadius
                    startAngle:endAngle
                      endAngle:startAngle
                     clockwise:false];
    }
    [path closePath];
    return path;
}

@end
