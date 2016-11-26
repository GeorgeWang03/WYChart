//
//  WYLineChartMainLineView.m
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYLineChartMainLineView.h"
#import "WYLineChartView.h"
#import "WYLineChartPoint.h"
#import "WYLineChartJunctionShape.h"
#import "WYLineChartCalculator.h"
#import <objc/runtime.h>
#import "WYChartCategory.h"
#import "WYLineChartDefine.h"

#define DEFAULT_LINE_WIDTH 2.5
#define DEFAULT_WAVE_RANGE 25
#define DEFAULT_RISE_HEIGHT 7
#define DEFAULT_WAVE_AMPLITUDE 25
#define DEFAULT_TIMING_FUNCTION [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]

NSString * const kWYLineChartLineAttributeLineWidth = @"kWYLineChartLineAttributeLineWidth";
NSString * const kWYLineChartLineAttributeLineStyle = @"kWYLineChartLineAttributeLineStyle";
NSString * const kWYLineChartLineAttributeLineColor = @"kWYLineChartLineAttributeLineColor";
NSString * const kWYLineChartLineAttributeLineDashPattern = @"kWYLineChartLineAttributeLineDashPattern";

NSString * const kWYLineChartLineAttributeDrawGradient = @"kWYLineChartLineAttributeDrawGradient";

NSString * const kWYLineChartLineAttributeShowJunctionShape = @"kWYLineChartLineAttributeShowJunctionShape";
NSString * const kWYLineChartLineAttributeJunctionColor = @"kWYLineChartLineAttributeJunctionColor";
NSString * const kWYLineChartLineAttributeJunctionStyle = @"kWYLineChartLineAttributeJunctionStyle";
NSString * const kWYLineChartLineAttributeJunctionSize = @"kWYLineChartLineAttributeJunctionSize";

@interface WYLineChartMainLineView ()

@property (nonatomic, strong) UILongPressGestureRecognizer *pressGestureRecognize;
@property (nonatomic, strong) WYLineChartJunctionShape *movingPoint;

@property (nonatomic, strong) NSArray *animationControlPoints;
@property (nonatomic, strong) CAShapeLayer *lineShapeLayer;
@property (nonatomic, strong) CAShapeLayer *gradientMaskLayer;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation WYLineChartMainLineView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_pressGestureRecognize) {
        [self setupLongPressGestureRecognize];
    }
}


- (void)drawRect:(CGRect)rect {
    
    self.pathSegments = [_parentView.calculator recalculatePathSegmentsForPoints:_points
                                                             withLineStyle:_style];
    
    void(^DrawJunctionShape)() = ^{
        //* * * * * * * * * * * * * * * * * * * *//
        //          Draw Junction Shape          //
        //* * * * * * * * * * * * * * * * * * * *//
        if (_junctionStyle != kWYLineChartJunctionShapeNone && _showJunctionShape) {
            
            [_points enumerateObjectsUsingBlock:^(WYLineChartPoint * point, NSUInteger idx, BOOL * _Nonnull stop) {
                
                WYLineChartJunctionShape *shape = [[WYLineChartJunctionShape alloc] initWithStyle:_junctionStyle
                                                                                             size:_junctionSize
                                                                                           origin:CGPointZero];
                shape.center = CGPointMake(point.x, point.y);
                shape.strokeColor = _junctionColor;
                shape.fillColor = _junctionColor;
                shape.backgroundColor = [UIColor clearColor];
                shape.layer.opacity = 0;
                
                CGFloat delay;
                delay = _animationStyle == kWYLineChartAnimationSpring ?
                _animationDuration*idx/_points.count + _animationDuration
                : _animationDuration*idx/_points.count;
                
                [self addSubview:shape];
                
                [self addScaleSpringAnimationForView:shape reverse:false
                                               delay:delay
                                          forKeyPath:@"original"];
            }];
        }
    };
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    if (_points.count < 2) {
        
        DrawJunctionShape();
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
#pragma clang diagnostic pop

    // add touchView to self
    if (_touchView) [self addSubview:_touchView];
    
    //* * * * * * * * * * * * * * * * * * * *//
    //          Draw Moving Point            //
    //* * * * * * * * * * * * * * * * * * * *//
    _movingPoint = [[WYLineChartJunctionShape alloc] initWithStyle:_touchPointStyle
                                                              size:_touchPointSize
                                                            origin:CGPointZero];
    _movingPoint.strokeColor = _touchPointColor;
    _movingPoint.fillColor = _touchPointColor;
    _movingPoint.backgroundColor = [UIColor clearColor];
    _movingPoint.hidden = true;
    [self addSubview:_movingPoint];
    
    //* * * * * * * * * * * * * * * * * * * *//
    //               Draw Line               //
    //* * * * * * * * * * * * * * * * * * * *//
    
    CGPoint firstPoint, lastPoint;
    CGPoint heighestPoint;
    
    firstPoint = ((WYLineChartPoint *)[_points firstObject]).point;
    lastPoint = ((WYLineChartPoint *)[_points lastObject]).point;
    
    UIBezierPath *linePath;
    UIBezierPath *linePathLower;
    UIBezierPath *linePathHigher;
    WYLineChartPoint *point;
    CAShapeLayer *lineLayer;
    
    WYLineChartPathSegment *pathSegment;
    
    if (_style != kWYLineChartMainNoneLine) {
        
        
        // 1.set up layer
        lineLayer = [CAShapeLayer layer];
        lineLayer.strokeColor = _lineColor.CGColor;
        lineLayer.fillColor = [UIColor clearColor].CGColor;
        lineLayer.backgroundColor = [UIColor clearColor].CGColor;
        lineLayer.lineWidth = _lineWidth;
        if (_lineDashPattern) lineLayer.lineDashPattern = _lineDashPattern;
        _lineShapeLayer = lineLayer;
        
        // 2. add to super layer
        [self.layer addSublayer:lineLayer];
        
        // if animation style is wave, we got to do other jobs later
        if (_animationStyle != kWYLineChartAnimationSpring) {
            // 3. set up path
            linePath = [UIBezierPath bezierPath];
            linePathLower = [UIBezierPath bezierPath];
            linePathHigher = [UIBezierPath bezierPath];
            point = _points[0];
            //
            //        currentPoint = CGPointMake(point.x, point.y);
            //        currentLowerPoint = CGPointMake(point.x, point.y - DEFAULT_WAVE_RANGE);
            //        currentHigherPoint = CGPointMake(point.x, point.y + DEFAULT_WAVE_RANGE);
            //
            [linePath moveToPoint:CGPointMake(point.x, point.y)];
            [linePathLower moveToPoint:CGPointMake(point.x, point.y + DEFAULT_RISE_HEIGHT)];
            //        [linePathHigher moveToPoint:currentHigherPoint];
            
            for (NSInteger idx = 0; idx < _pathSegments.count; ++idx) {
                
                pathSegment = _pathSegments[idx];
                ////            point = _parentView.points[idx];
                //            newPoint = CGPointMake(point.x, point.y);
                //            newLowerPoint = CGPointMake(point.x, point.y - pow(-1, idx) * DEFAULT_WAVE_RANGE);
                //            newHigherPoint = CGPointMake(point.x, point.y + pow(-1, idx) *  DEFAULT_WAVE_RANGE);
                
                switch (_style) {
                    case kWYLineChartMainStraightLine:
                        [linePath addLineToPoint:pathSegment.endPoint.point];
                        [linePathLower addLineToPoint:[self pointBelowPoint:pathSegment.endPoint.point forDistance:DEFAULT_RISE_HEIGHT]];
                        break;
                    case kWYLineChartMainBezierWaveLine:
                    case kWYLineChartMainBezierTaperLine:
                        //normal linepath
                        [linePath addQuadCurveToPoint:pathSegment.endPoint.point controlPoint:pathSegment.controlPoint.point];
                        // lower linepath
                        [linePathLower addQuadCurveToPoint:[self pointBelowPoint:pathSegment.endPoint.point forDistance:DEFAULT_RISE_HEIGHT]
                                              controlPoint:[self pointBelowPoint:pathSegment.controlPoint.point forDistance:DEFAULT_RISE_HEIGHT]];
                        break;
                    default:
                        break;
                }
            }
            
            lineLayer.path = linePath.CGPath;
        }
    }
    
    //* * * * * * * * * * * * * * * * * * * *//
    //            Draw Gradient              //
    //* * * * * * * * * * * * * * * * * * * *//
    
    CAGradientLayer *gradientLayer;
    CAShapeLayer *maskLayer;
    
    UIBezierPath *gradientPath;
    UIBezierPath *gradientPathLower;
    
    if (_drawGradient && _style != kWYLineChartMainNoneLine) {
        
        // transfer UIColor to CGColor
        NSArray *gradientColors = @[[_lineColor colorWithAlphaComponent:0.6],
                                    [_lineColor colorWithAlphaComponent:0.0]];
        NSArray *gradientLocation = @[@0, @.95];
        NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:gradientColors];
        [gradientColors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGColorRef cgColor;
            if ([obj isKindOfClass:[UIColor class]]) {
                cgColor = ((UIColor *)obj).CGColor;
            } else {
                cgColor = (__bridge CGColorRef)(obj);
            }
            [cgColors addObject:(__bridge id)cgColor];
        }];
        
        maskLayer = [CAShapeLayer layer];
        maskLayer.strokeColor = [UIColor clearColor].CGColor;
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        _gradientMaskLayer = maskLayer;
        
        gradientLayer = [CAGradientLayer layer];
        [gradientLayer setFrame:self.bounds];
        gradientLayer.mask = maskLayer;
        gradientLayer.colors = cgColors;
        gradientLayer.locations = gradientLocation;
        
        [self.layer addSublayer:gradientLayer];
        
        // if animation style is wave, we got to do other jobs later
        if (_animationStyle != kWYLineChartAnimationSpring) {
            
            //heighestPoint = [_parentView.calculator maxValueOfPoints:_parentView.points].point;
            
            gradientPath = [UIBezierPath bezierPathWithCGPath:linePath.CGPath];
            gradientPathLower = [UIBezierPath bezierPathWithCGPath:linePathLower.CGPath];
            
            [gradientPath addLineToPoint:CGPointMake(lastPoint.x, boundsHeight)];
            [gradientPath addLineToPoint:CGPointMake(firstPoint.x, boundsHeight)];
            [gradientPath addLineToPoint:firstPoint];
            //
            [gradientPathLower addLineToPoint:CGPointMake(lastPoint.x, boundsHeight)];
            [gradientPathLower addLineToPoint:CGPointMake(firstPoint.x, boundsHeight)];
            [gradientPathLower addLineToPoint:CGPointMake(firstPoint.x, firstPoint.y - DEFAULT_RISE_HEIGHT)];
            //
            //        [gradientPathHigher addLineToPoint:CGPointMake(currentPoint.x, boundsHeight)];
            //        [gradientPathHigher addLineToPoint:CGPointMake(point.x, boundsHeight)];
            //        [gradientPathHigher addLineToPoint:CGPointMake(point.x, point.y + DEFAULT_WAVE_RANGE)];
            maskLayer.path = gradientPath.CGPath;
        }
    }
    
    //* * * * * * * * * * * * * * * * * * * *//
    //            Animation                  //
    //* * * * * * * * * * * * * * * * * * * *//
    
    if (_animationStyle != kWYLineChartNoneAnimation
        && _animationStyle != kWYLineChartAnimationSpring) {
        
        CABasicAnimation *animation;
        CABasicAnimation *costarAnimation;
        
        if (_animationStyle == kWYLineChartAnimationAlpha) {
            
            animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.duration = _animationDuration;
            animation.fromValue = @(0.0);
            animation.toValue = @(1.0);
            [lineLayer addAnimation:animation forKey:@"opacity"];
        } else if (_animationStyle == kWYLineChartAnimationDrawing) {
            
            animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.duration = _animationDuration;
            animation.fromValue = @(0.0);
            animation.toValue = @(1.0);
            [lineLayer addAnimation:animation forKey:@"strokeEnd"];
        } else if (_animationStyle == kWYLineChartAnimationWidth) {
            
            animation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
            animation.duration = _animationDuration;
            animation.fromValue = @(0.0);
            animation.toValue = @(DEFAULT_LINE_WIDTH);
            [lineLayer addAnimation:animation forKey:@"lineWidth"];
        } else if (_animationStyle == kWYLineChartAnimationRise) {
            
            UIBezierPath *rigionPath = linePathLower;

            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
            animation.duration = _animationDuration;
            animation.fromValue = (__bridge id _Nullable)(rigionPath.CGPath);
            animation.toValue = (__bridge id _Nullable)(linePath.CGPath);
            [lineLayer addAnimation:animation forKey:@"path"];
        }
        //animation for gradient
        animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration = _animationDuration;
        animation.speed = 1.5;
        animation.fromValue = @0.0;
        animation.toValue = @1.0;
        
        costarAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        costarAnimation.duration = _animationDuration;
        costarAnimation.speed = 1.5;
        costarAnimation.fromValue = (__bridge id _Nullable)(gradientPathLower.CGPath);
        costarAnimation.toValue = (__bridge id _Nullable)(gradientPath.CGPath);
        
        [gradientLayer addAnimation:animation forKey:nil];
        [maskLayer addAnimation:costarAnimation forKey:nil];
    }
    
    //* * * * * * * * * * * * * * * * * * * *//
    //          Draw Junction Shape          //
    //* * * * * * * * * * * * * * * * * * * *//
    DrawJunctionShape();
    
    //* * * * * * * * * * * * * * * * * * * *//
    //         reset subviews' order         //
    //* * * * * * * * * * * * * * * * * * * *//
    [self.layer insertSublayer:lineLayer above:gradientLayer];
    [self bringSubviewToFront:_touchView];
    [self bringSubviewToFront:_movingPoint];
    
    //* * * * * * * * * * * * * * * * * * * *//
    //    reset wave path control point      //
    //* * * * * * * * * * * * * * * * * * * *//
    
    if (_animationStyle == kWYLineChartAnimationSpring) {
    
        if (!_displayLink) {
            _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleWaveFrameUpdate)];
            [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            _displayLink.paused = true;
        }
        
        __block UIView *shape;
        CGFloat middleY = (firstPoint.y + lastPoint.y) / 2;
        NSMutableArray *controlPoints = [NSMutableArray array];
        [_points enumerateObjectsUsingBlock:^(WYLineChartPoint * point, NSUInteger idx, BOOL * _Nonnull stop) {
            
            shape = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 2)];
            
            shape.center = CGPointMake(point.x, 2*middleY-point.y/* - _parentView.lineBottomMargin*/);
            shape.backgroundColor = [UIColor clearColor];
            [self addSubview:shape];
            [controlPoints addObject:shape];
        }];
        _animationControlPoints = controlPoints;
        
        _displayLink.paused = false;
        self.userInteractionEnabled = false;
        [UIView animateWithDuration:_animationDuration + 0.5
                              delay:0.0
             usingSpringWithDamping:0.15
              initialSpringVelocity:1.40
                            options:0//UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [_animationControlPoints enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
                                 view.center = CGPointMake(view.center.x, ((WYLineChartPoint *)_points[idx]).y);
                             }];
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 _displayLink.paused = true;
                                 self.userInteractionEnabled = true;
                             }
                         }];
    }
}




#pragma mark - setter and getter

- (void)setTouchable:(BOOL)touchable {
    _touchable = touchable;
    _pressGestureRecognize.enabled = _touchable;
}

- (void)setTouchView:(UIView *)touchView {
    
    
    if (!touchView) return;
    
    // scale touch view
    CGFloat yScale = 1.0;
    CGFloat xScale = 1.0;
    CGFloat transformScale = 1.0;
    
    CGFloat maxHeight = CGRectGetHeight(self.bounds) / 4;
    CGFloat maxWidth = CGRectGetWidth(self.bounds) / 4;
    
    CGFloat touchViewHeight = CGRectGetHeight(touchView.frame);
    CGFloat touchViewWidth = CGRectGetWidth(touchView.frame);
    
    if (touchViewHeight > maxHeight) {
        yScale = maxHeight / touchViewHeight;
    }
    
    if (touchViewWidth > maxWidth) {
        xScale = maxWidth / touchViewWidth;
    }
    
    transformScale = xScale < yScale ? xScale : yScale;
    touchView.transform = CGAffineTransformScale(CGAffineTransformIdentity, transformScale, transformScale);
    
    touchView.alpha = 0.0;
    
    if (_touchView) [_touchView removeFromSuperview];
    _touchView = touchView;
    [self addSubview:_touchView];
}

#pragma mark - wave animation

- (void)handleWaveFrameUpdate {
    
    [_points enumerateObjectsUsingBlock:^(WYLineChartPoint *point, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = _animationControlPoints[idx];
        point.x = [view wy_centerForPresentationLayer:true].x;
        point.y = [view wy_centerForPresentationLayer:true].y;
    }];
    
    UIBezierPath *linePath = [self currentLinePathForWave];
    _lineShapeLayer.path = linePath.CGPath;
    
    if (_drawGradient) {
        WYLineChartPoint *firstPoint, *lastPoint;
        firstPoint = [_points firstObject];
        lastPoint = [_points lastObject];
        
        UIBezierPath *gradientPath = [UIBezierPath bezierPathWithCGPath:linePath.CGPath];
        [gradientPath addLineToPoint:CGPointMake(lastPoint.x, self.wy_boundsHeight)];
        [gradientPath addLineToPoint:CGPointMake(firstPoint.x, self.wy_boundsHeight)];
        [gradientPath addLineToPoint:firstPoint.point];
        
        _gradientMaskLayer.path = gradientPath.CGPath;
    }
}

- (UIBezierPath *)currentLinePathForWave {
    
    NSArray *segments = [_parentView.calculator recalculatePathSegmentsForPoints:_points withLineStyle:_style];
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    
    WYLineChartPathSegment *pathSegment;
    WYLineChartPoint *point = _points[0];
    
    [linePath moveToPoint:CGPointMake(point.x, point.y)];
    
    for (NSInteger idx = 0; idx < segments.count; ++idx) {
        
        pathSegment = segments[idx];
        
        switch (_style) {
            case kWYLineChartMainStraightLine:
                [linePath addLineToPoint:pathSegment.endPoint.point];
                break;
            case kWYLineChartMainBezierWaveLine:
            case kWYLineChartMainBezierTaperLine:
                [linePath addQuadCurveToPoint:pathSegment.endPoint.point controlPoint:pathSegment.controlPoint.point];
                break;
            default:
                break;
        }
    }
    
    return linePath;
}

#pragma mark - gesture recognize

- (void)setupLongPressGestureRecognize {
    
    _pressGestureRecognize = [[UILongPressGestureRecognizer alloc] init];
    [_pressGestureRecognize addTarget:self action:@selector(handleGestureRecognize:)];
    _pressGestureRecognize.minimumPressDuration = 0.7;
    _pressGestureRecognize.enabled = _touchable;
    [self addGestureRecognizer:_pressGestureRecognize];
}

- (void)handleGestureRecognize:(UIGestureRecognizer *)recognize {
   
//    NSLog(@"gesture.view = %@", recognize.view);
    CGPoint location = [recognize locationInView:self];
    NSLog(@"location : %@", NSStringFromCGPoint(location));
    
    WYLineChartPoint *originalPoint;
    WYLineChartPathSegment *segment;
    CGFloat locationOnBezierPath;
    CGPoint movingPoint;
    CGPoint touchViewCenter;
    CGFloat maxX, minX;
    SEL selector = nil;
    
    maxX = ((WYLineChartPoint *)[_points lastObject]).x - 1;
    minX = ((WYLineChartPoint *)[_points firstObject]).x + 1;
    
    segment = [_parentView.calculator segmentForPoint:location
                                           inSegments:_pathSegments];
    
    if (!segment) {
        if (!_movingPoint.isHidden
            && (recognize.state == UIGestureRecognizerStateEnded
                || recognize.state == UIGestureRecognizerStateCancelled
                || recognize.state == UIGestureRecognizerStateRecognized)) {
            originalPoint = movingPoint.x <= minX ? [_points firstObject] : [_points lastObject];
            movingPoint = originalPoint.point;
            [self addScaleSpringAnimationForView:_movingPoint reverse:true delay:0 forKeyPath:@"moving"];
            selector = @selector(mainLineView:didEndedTouchAtPoint:belongToSegmentOfPoint:);
            [UIView animateWithDuration:0.8 animations:^{
                _touchView.alpha = 0.0;
            } completion:^(BOOL finished) {
                _movingPoint.hidden = true;
            }];
        }
    } else {
        originalPoint = [segment originalPointForPoint:location];
        locationOnBezierPath = [segment yValueCalculteFromQuadraticFormulaForPoint:location];
        // moving point
        movingPoint = CGPointMake(location.x, locationOnBezierPath);
        _movingPoint.center = movingPoint;
        // touchview center
        // 1.recalculate scale from touchview's transform
        // reference from : (http://stackoverflow.com/questions/2690337/get-just-the-scaling-transformation-out-of-cgaffinetransform)
        CGFloat scale = sqrt(_touchView.transform.a * _touchView.transform.a + _touchView.transform.c * _touchView.transform.c);
        NSInteger para = movingPoint.y > CGRectGetHeight(self.bounds) / 2 ? 1 : -1;
        touchViewCenter.x = movingPoint.x;
        touchViewCenter.y = movingPoint.y + para * ( 5 + scale * CGRectGetWidth(_touchView.frame)/2);
        _touchView.center = touchViewCenter;
        //    NSLog(@"touch view frame : %@", NSStringFromCGRect(_touchView.frame));
        
        
        if (recognize.state == UIGestureRecognizerStateEnded
            || recognize.state == UIGestureRecognizerStateCancelled
            || recognize.state == UIGestureRecognizerStateRecognized
            )/*|| movingPoint.x <= minX || movingPoint.x >= maxX*/ {
//            NSLog(@"gesture end with state : %lu", recognize.state);
            
            [self addScaleSpringAnimationForView:_movingPoint reverse:true delay:0 forKeyPath:@"moving"];
            selector = @selector(mainLineView:didEndedTouchAtPoint:belongToSegmentOfPoint:);
            
            [UIView animateWithDuration:0.8 animations:^{
                _touchView.alpha = 0.0;
            } completion:^(BOOL finished) {
                _movingPoint.hidden = true;
            }];
        } else if (recognize.state == UIGestureRecognizerStateBegan) {
            
            _movingPoint.hidden = false;
            [self addScaleSpringAnimationForView:_movingPoint reverse:false delay:0 forKeyPath:@"moving"];
            selector = @selector(mainLineView:didBeganTouchAtPoint:belongToSegmentOfPoint:);
            
            [UIView animateWithDuration:0.5 animations:^{
                _touchView.alpha = 1.0;
            }];
            
        } else if (recognize.state == UIGestureRecognizerStateChanged) {
            selector = @selector(mainLineView:didmovedTouchToPoint:belongToSegmentOfPoint:);
        }
    }
    
    if (selector) {
        NSMethodSignature *signature = [_parentView methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        if (invocation) {
            
            [invocation setSelector:selector];
            [invocation setTarget:_parentView];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
            [invocation setArgument:&self atIndex:2];
#pragma clang diagnostic pop
            [invocation setArgument:&movingPoint
                            atIndex:3];
            [invocation setArgument:&originalPoint
                            atIndex:4];
            [invocation invoke];
        }
    }
}

- (void)addScaleSpringAnimationForView:(UIView *)view reverse:(BOOL)isReverse delay:(CGFloat)delay forKeyPath:(NSString *)keyPath {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.keyTimes = !isReverse ? @[@0.05, @0.5, @0.9] : @[@0.5, @0.9];
    animation.values = !isReverse ? @[@0.01, @2.5, @1.0] : @[@2.5, @0.01];
    
    CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    baseAnimation.fromValue = isReverse ? @1.0 : @0.5;
    baseAnimation.toValue = isReverse ? @0.5 : @1.0;
    
    CAAnimationGroup *groundAnimation = [[CAAnimationGroup alloc] init];
    groundAnimation.duration = 0.5;
    groundAnimation.speed = 0.5;
    groundAnimation.animations = @[animation, baseAnimation];
    groundAnimation.delegate = self;
    groundAnimation.beginTime = CACurrentMediaTime() + delay;
//    groundAnimation.timingFunction = DEFAULT_TIMING_FUNCTION;
    [groundAnimation setValue:view.layer forKey:keyPath];
    
    [view.layer addAnimation:groundAnimation forKey:nil];
}

- (void)animationDidStart:(CAAnimation *)anim {
    
    CALayer *layer = [anim valueForKeyPath:@"original"];
    if (layer) {
        layer.opacity = 1.0;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    CALayer *layer = [anim valueForKeyPath:@"original"];
    if (layer) {
        [anim setValue:nil forKeyPath:@"original"];
    }
}

- (CGPoint)pointBelowPoint:(CGPoint)point forDistance:(CGFloat)distance {
    
    return CGPointMake(point.x, point.y + distance);
}

@end
