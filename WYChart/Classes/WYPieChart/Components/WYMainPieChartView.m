//
//  WYMainPieChartView.m
//  WYChart
//
//  Created by yingwang on 16/8/13.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYMainPieChartView.h"
#import "WYChartCategory.h"
#import "WYPieSector.h"
#import "WYPieChartView.h"
#import "WYSectorLayer.h"
#import "WYPieChartCalculator.h"
#define DEGREES_IN_RADIANS(x) (M_PI * x / 180.0)
#define DEFAULT_INNER_MARGIN 20

@interface WYMainPieChartView () <UIGestureRecognizerDelegate>


///////--------------------------------------- For Rotate And Tap------------------------------------------///////
@property (nonatomic) BOOL canRotate;
@property (nonatomic) NSInteger draggedIndex;
@property (nonatomic) CGFloat beginningDragDistance;
@property (nonatomic) CGPoint currentPanPoint;
@property (nonatomic) CGFloat currentRotateAngle;
@property (nonatomic) CGFloat generalRotateAngle;
@property (nonatomic) CATransform3D currentTransform;

///////--------------------------------------- For Animation ------------------------------------------///////

@property (nonatomic) BOOL canAnimate;
@property (nonatomic) BOOL animating;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) UIView *controlPoint;
@property (nonatomic, strong) NSMutableArray *currentSectorLayers;

@property (nonatomic, strong) CALayer *draggingControlPoint;

@end

@implementation WYMainPieChartView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//        [self addGestureRecognizer:tapGesture];
//        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//        [self addGestureRecognizer:panGesture];
//        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//        [self addGestureRecognizer:swipeGesture];
    }
    return self;
}

#pragma mark - draw content

- (void)drawRect:(CGRect)rect {
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    if (_link) {
        [_link invalidate];
    }
    
//    UIColor *fillColor;
    WYSectorLayer *pieLayer;
//    CAShapeLayer *maskLayer;
//    WYPieSector *currentSector;
    NSMutableArray *sectorLayers;
    _generalRotateAngle = 0;
    self.layer.transform = CATransform3DIdentity;
    
    //* * * * * * * * * * * * * * * * * * * *//
    //              Draw Sector              //
    //* * * * * * * * * * * * * * * * * * * *//
    
    sectorLayers = [NSMutableArray array];
    
    if (_animationStyle == kWYPieChartAnimationAlpha
        || _animationStyle == kWYPieChartAnimationScale
        || _animationStyle == kWYPieChartAnimationStretching
        || _animationStyle == kWYPieChartAnimationNone) {
        
        for (NSInteger idx = 0; idx < _sectors.count; ++idx) {
            
            pieLayer = [self createSectorLayerWithSector:_sectors[idx]
                                                 atIndex:idx];
            
            [self.layer addSublayer:pieLayer];
            [sectorLayers addObject:pieLayer];
        }
        _currentSectorLayers = sectorLayers;
    }
    
    //* * * * * * * * * * * * * * * * * * * *//
    //           Setup Animation             //
    //* * * * * * * * * * * * * * * * * * * *//
    
    CGFloat delay;
    
    if (_animationStyle == kWYPieChartAnimationOrderlySpreading
        ||_animationStyle == kWYPieChartAnimationAllSpreading) {
        
        CGRect frame;
        CGPoint startPoint;
        startPoint.x = self.wy_boundsCenter.x;
        startPoint.y = self.wy_boundsCenter.y - self.sectorsRadius;
        frame.origin = startPoint;
        frame.size = CGSizeMake(1, 1);
        
        _currentSectorLayers = [NSMutableArray array];
        
        _controlPoint = [[UIView alloc] initWithFrame:frame];
        _controlPoint.backgroundColor = [UIColor clearColor];
        _controlPoint.center = frame.origin;
        [self addSubview:_controlPoint];
        
        if (_animationStyle == kWYPieChartAnimationAllSpreading) {
            CASpringAnimation *animation = [CASpringAnimation animationWithKeyPath:@"position.x"];
            animation.fromValue = @(_controlPoint.layer.position.x);
            animation.toValue = @(_controlPoint.layer.position.x+20);
            animation.damping = 5;
            animation.duration = animation.settlingDuration +1.2;
            animation.delegate = self;
            [animation setValue:_controlPoint.layer forKey:@"spreading"];
            
            [_controlPoint.layer addAnimation:animation forKey:@"spreading"];
        } else {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
            animation.fromValue = @(_controlPoint.layer.position.x);
            animation.toValue = @(_controlPoint.layer.position.x+20);
            animation.duration = _animationDuration;
            animation.delegate = self;
            [animation setValue:_controlPoint.layer forKey:@"spreading"];
            
            [_controlPoint.layer addAnimation:animation forKey:@"spreading"];
        }

        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(spreadAnimationReload)];
        [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
    } else if (_animationStyle == kWYPieChartAnimationAlpha
               || _animationStyle == kWYPieChartAnimationStretching
               || _animationStyle == kWYPieChartAnimationScale) {
        
        //set up animation flag which means a layer already animated by 1 otherwise 0
        int *flag = (int *)malloc((_sectors.count)*sizeof(int));
        memset(flag, 0, sizeof(int)*_sectors.count);
        
        delay = 0;
        int sectorIdx;
        for (int time = 0; time < _sectors.count; ++ time) {
            while (true) {
                sectorIdx = arc4random_uniform((u_int32_t)_sectors.count);
                if (!flag[sectorIdx]) {
                    break;
                }
            }
            flag[sectorIdx] = 1;
            pieLayer = sectorLayers[sectorIdx];
            
            if (_animationStyle == kWYPieChartAnimationAlpha) {
                
                pieLayer.opacity = 0.0;
                [pieLayer addAlphaAnimationWithDuration:_animationDuration - delay
                                                  delay:delay
                                                toValue:1.0
                                               delegate:self];
            } else if (_animationStyle == kWYPieChartAnimationStretching) {
                
                [pieLayer addStretchAnimationWithDuration:_animationDuration
                                                    delay:delay
                                                 delegate:self];
            } else if (_animationStyle == kWYPieChartAnimationScale) {
                
               pieLayer.opacity = 0.0;
                [pieLayer addScaleAnimationWithDuration:_animationDuration
                                                  delay:delay
                                               delegate:self];
            }
            
            delay += _animationDuration/_sectors.count/2;
        }
    }
}

#pragma mark - animation deleagete

- (void)animationDidStart:(CAAnimation *)anim {
    
//    NSLog(@"start");
//    _animating = true;
    
    CALayer *layer = [anim valueForKeyPath:@"scale"];
    if (layer) {
        layer.opacity = 1.0;
    }
    
    layer = [anim valueForKeyPath:@"spreading"];
    if (layer) {
        [self resetSectorState];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    _animating = false;
    if (!flag) {
        return;
    }
    
    [_link invalidate];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_parentView performSelector:@selector(chartAnimationDidStop)];
#pragma clang diagnostic pop
    
    CALayer *layer = [anim valueForKeyPath:@"opacity"];
    if (layer) {
        layer.opacity = 1.0;
        [anim setValue:nil forKey:@"opacity"];
    }
    
    layer = [anim valueForKeyPath:@"scale"];
    if (layer) {
        layer.opacity = 1.0;
        //        layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
        [anim setValue:nil forKey:@"scale"];
    }
    
    layer = [anim valueForKeyPath:@"spreading"];
    if (layer && layer == _controlPoint.layer) {
        WYSectorLayer *pieLayer;
        CAShapeLayer *mask;
        for (NSInteger idx = 0; idx < _sectors.count; ++idx) {
            pieLayer = _currentSectorLayers[idx];
            mask = (CAShapeLayer *)pieLayer.mask;
            mask.path = [self pathForSector:_sectors[idx]].CGPath;
        }
        [anim setValue:nil forKey:@"spreading"];
    }
    
//    layer = [anim valueForKeyPath:@"draggingSpring"];
//    if (layer) {
//        [_link invalidate];
//        _link = nil;
//        [anim setValue:nil forKey:@"draggingSpring"];
//    }
//    NSLog(@"end");
}

#pragma mark - getter and setter

- (CGFloat)sectorsRadius {
    return (self.wy_boundsWidth - 2*DEFAULT_INNER_MARGIN) / 2;
}


#pragma mark - Shape Creating Methor

- (WYSectorLayer *)createSectorLayerWithSector:(WYPieSector *)sector atIndex:(NSInteger)idx {
    
    UIColor *fillColor;
    WYSectorLayer *pieLayer;
    CAShapeLayer *maskLayer;
    WYPieSector *currentSector;
    
    fillColor = [_parentView.datasource pieChartView:_parentView
                                  sectorColorAtIndex:idx];
    currentSector = sector;
    currentSector.color = fillColor;
    currentSector.fillByGradient = _fillByGradient;
    
    pieLayer = [WYSectorLayer layerWithSectorInfo:currentSector];
    pieLayer.frame = self.bounds;
    
    //pieLayer.path = [self pathForSector:currentSector].CGPath;
    pieLayer.strokeColor = [UIColor whiteColor].CGColor;//_strokeColor.CGColor;
    pieLayer.lineWidth = 3;//_lineWidth;
    //pieLayer.fillColor = [UIColor clearColor].CGColor;
    
    maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = [self pathForSector:currentSector].CGPath;
    maskLayer.strokeColor = [UIColor clearColor].CGColor;
    maskLayer.lineWidth = 4;
    //        maskLayer.fillColor = [UIColor clearColor].CGColor;
    pieLayer.mask = maskLayer;
    
    return pieLayer;
}

- (UIBezierPath *)pathForSector:(WYPieSector *)sector {
    
    return [self sectorPathWithVertex:sector.vertex
                               radius:sector.radius
                          innerRadius:sector.innerRadius
                           startAngle:sector.startAngle
                             endAngle:sector.endAngle];
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

- (void)spreadAnimationReload {
    
    CGFloat maxAngle;
    WYSectorLayer *pieLayer;
    CAShapeLayer *mask;
    maxAngle = ([_controlPoint.layer wy_centerForPresentationLayer:true].x-self.wy_boundsCenter.x)/10;
//    NSLog(@"angle = %f", maxAngle);
    if (maxAngle > 2) maxAngle = 4 - maxAngle;
    maxAngle *= M_PI;
    maxAngle -= M_PI_2;
//    NSLog(@"angle = %f", maxAngle/M_PI);
    
    if (!_currentSectorLayers) _currentSectorLayers = [NSMutableArray array];
    NSArray *currentSectors;
    
    if (_animationStyle == kWYPieChartAnimationOrderlySpreading) {
        currentSectors = [_parentView.calculator createSectorFromSectors:_sectors
                                                                maxAngle:maxAngle];
    } else if (_animationStyle == kWYPieChartAnimationAllSpreading) {
        currentSectors = [_parentView.calculator createSectorsForValues:_parentView.values
                                                                atPoint:self.wy_boundsCenter
                                                                 radius:self.sectorsRadius
                                                               maxAngle:maxAngle
                                                               pieStyle:_style showInnerCircle:_showInnerCircle];
    }
    
    for (int idx = 0; idx < currentSectors.count; ++idx) {
        if (idx < _currentSectorLayers.count) {
            pieLayer = _currentSectorLayers[idx];
        } else {
            pieLayer = [self createSectorLayerWithSector:_sectors[idx]
                                                 atIndex:idx];
            [_currentSectorLayers addObject:pieLayer];
        }
        mask = (CAShapeLayer *)pieLayer.mask;
        mask.path = [self pathForSector:currentSectors[idx]].CGPath;
        [self.layer addSublayer:pieLayer];
    }
}

#pragma mark - manage touch

- (void)resetSectorState {
    
    [_currentSectorLayers enumerateObjectsUsingBlock:^(WYSectorLayer *layer, NSUInteger idx, BOOL * _Nonnull stop) {
        if (layer.selected) {
            WYPieSector *sector = _sectors[idx];
            CGPoint translatePoint = CGPointMake(layer.position.x-20*cosf(sector.centerAngle),
                                                 layer.position.y-20*sinf(sector.centerAngle));
            layer.position = translatePoint;
            layer.selected = false;
        }
    }];
}

//- (void)draggingReload {
//    
//    WYPieSector *sector = _sectors[_draggedIndex];
//    WYSectorLayer *layer = _currentSectorLayers[_draggedIndex];
//    CGFloat radius = sector.radius + ((CALayer *)_draggingControlPoint.presentationLayer).position.x;
//    UIBezierPath *path = [self sectorPathWithVertex:sector.vertex
//                                             radius:radius
//                                         startAngle:sector.startAngle
//                                           endAngle:sector.endAngle];
//    ((CAShapeLayer *)layer.mask).path = path.CGPath;
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touch");
    
    _canRotate = false;
    _currentTransform = self.layer.transform;
    _currentRotateAngle = 0;
    _currentPanPoint = [[touches anyObject] locationInView:_parentView];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
//    NSLog(@"touch at : %@", NSStringFromCGPoint(point));
    
    if (_selectable && !_animating) {
        [_currentSectorLayers enumerateObjectsUsingBlock:^(WYSectorLayer *layer, NSUInteger idx, BOOL * _Nonnull stop) {
            CGAffineTransform transform = CGAffineTransformIdentity;
            if (CGPathContainsPoint(((CAShapeLayer *)layer.mask).path, &transform, point, false)) {
                layer.transform = CATransform3DScale(CATransform3DIdentity, 0.9, 0.9, 1.0);
            } else {
                layer.transform = CATransform3DIdentity;
            }
        }];
    }
    
    if (_draggable && !_animating) {
        [_currentSectorLayers enumerateObjectsUsingBlock:^(WYSectorLayer *layer, NSUInteger idx, BOOL * _Nonnull stop) {
            CGAffineTransform transform = CGAffineTransformIdentity;
            if (CGPathContainsPoint(((CAShapeLayer *)layer.mask).path, &transform, point, false)) {
                _draggedIndex = idx;
                CGPoint center = _parentView.wy_boundsCenter;
                CGPoint point = [[touches anyObject] locationInView:_parentView];
                CGFloat curAngle = atan2f((point.y - center.y),(point.x - center.x));
                WYPieSector *sector = _sectors[idx];
                _beginningDragDistance =  fabs(sqrtf(powf((point.x-center.x), 2)+powf((point.y-center.y), 2))
                                               *cosf(sector.centerAngle-curAngle));
            }
        }];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGPoint center = [self convertPoint:self.wy_boundsCenter toView:_parentView];
    CGPoint point;
    CGFloat preAngle;
    CGFloat curAngle;
    CGFloat rotateAngle;
    CGFloat panDistance;
    
    point = [[touches anyObject] locationInView:_parentView];
    
    curAngle = atan2f((point.y - center.y),(point.x - center.x));
    preAngle = atan2f((_currentPanPoint.y - center.y),(_currentPanPoint.x - center.x));
    rotateAngle = curAngle - preAngle;
    panDistance = sqrtf(powf((point.x-center.x), 2)+powf((point.y-center.y), 2));
   
    if (_draggable && !_animating) {
        WYSectorLayer *layer = _currentSectorLayers[_draggedIndex];
        WYPieSector *sector = _sectors[_draggedIndex];
        
        [layer stopAllAnimations];
        
        panDistance = fabs(cosf(sector.centerAngle-curAngle)*panDistance) - _beginningDragDistance;
//        NSLog(@"1  pandistance = %f", panDistance);
        if (panDistance > 150 || panDistance < -150) panDistance = 150 * fabs(panDistance)/panDistance;
        
        panDistance = 17 * (2*(fabs(panDistance)/150)-powf((fabs(panDistance)/150), 2))
                      *(fabs(panDistance)/panDistance);
//        NSLog(@"2  pandistance = %f", panDistance);
        panDistance += sector.radius;
        if (panDistance < sector.innerRadius+10 && panDistance > -(sector.innerRadius+10)) {
            panDistance = (sector.innerRadius+10) * fabs(panDistance)/panDistance;
        }
//        NSLog(@"3  pandistance = %f", panDistance);
        UIBezierPath *path = [self sectorPathWithVertex:sector.vertex
                                                 radius:panDistance
                                            innerRadius:sector.innerRadius
                                             startAngle:sector.startAngle
                                               endAngle:sector.endAngle];
        ((CAShapeLayer *)layer.mask).path = path.CGPath;
    }
    
    if (((rotateAngle < M_PI/16 && rotateAngle > -M_PI/16) && !_canRotate) || !_rotatabel) {
//        NSLog(@"return");
        return;
    } else {
        
        if (!_canRotate) {
            _currentPanPoint = point;
            rotateAngle = 0;
        }
        _canRotate = true;
//        NSLog(@"center point = %@", NSStringFromCGPoint(center));
//        NSLog(@"current point = %@", NSStringFromCGPoint(point));
//        NSLog(@"curAngle = %f, preAngle = %f", curAngle, preAngle);
//        NSLog(@"current angle = %f, rotate angle = %f", _currentRotateAngle, rotateAngle);
//        NSLog(@"pass");
    }
    
    _currentRotateAngle += rotateAngle;
    
    //    NSLog(@"curAngle = %f, preAngle = %f", curAngle, preAngle);
    //    NSLog(@"current angle = %f, rotate angle = %f", _currentRotateAngle, rotateAngle);
    
    //    self.transform = CGAffineTransformRotate(_currentTransform, _currentRotateAngle);
    self.layer.transform = CATransform3DRotate(_currentTransform, _currentRotateAngle, 0, 0, 1.0);
    _currentPanPoint = point;
    
    CGFloat angle = _currentRotateAngle+_generalRotateAngle;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSMethodSignature *signature = [_parentView methodSignatureForSelector:@selector(chartRotateAngle:)];
#pragma clang diagnostic pop
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    if (invocation) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [invocation setSelector:@selector(chartRotateAngle:)];
#pragma clang diagnostic pop
        
        [invocation setTarget:_parentView];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
        [invocation setArgument:&(angle) atIndex:2];
#pragma clang diagnostic pop
        [invocation invoke];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"end");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
//    NSLog(@"touch at : %@", NSStringFromCGPoint(point));
    _generalRotateAngle += _currentRotateAngle;
    
    if (_selectable && !_animating) {
        [_currentSectorLayers enumerateObjectsUsingBlock:^(WYSectorLayer *layer, NSUInteger idx, BOOL * _Nonnull stop) {
            CGAffineTransform transform = CGAffineTransformIdentity;
            if (CGPathContainsPoint(((CAShapeLayer *)layer.mask).path, &transform, point, false)
                && !_canRotate) {
                WYPieSector *sector = _sectors[idx];
                NSInteger direction = layer.selected ? -1 : 1;
                CGPoint translatePoint = CGPointMake(layer.position.x+20*cosf(sector.centerAngle)*direction,
                                                     layer.position.y+20*sinf(sector.centerAngle)*direction);
                layer.position = translatePoint;
                layer.selected = !layer.selected;
                
                if (layer.selected) {
                    if ([_parentView.delegate respondsToSelector:@selector(pieChartView:didSelectedSectorAtIndex:)]) {
                        [_parentView.delegate pieChartView:_parentView didSelectedSectorAtIndex:idx];
                    }
                }
            } else if (layer.selected) {
                WYPieSector *sector = _sectors[idx];
                NSInteger direction = -1;
                CGPoint translatePoint = CGPointMake(layer.position.x+20*cosf(sector.centerAngle)*direction,
                                                     layer.position.y+20*sinf(sector.centerAngle)*direction);
                layer.position = translatePoint;
                layer.selected = false;
            }
            layer.transform = CATransform3DIdentity;
        }];
    }
    
    if (_draggable && !_animating) {
        
        CGPoint center = _parentView.wy_boundsCenter;
        CGPoint point = [[touches anyObject] locationInView:_parentView];
        CGFloat curAngle = atan2f((point.y - center.y),(point.x - center.x));
        WYPieSector *sector = _sectors[_draggedIndex];
        WYSectorLayer *layer = _currentSectorLayers[_draggedIndex];
        CGFloat x =  fabs(sqrtf(powf((point.x-center.x), 2)+powf((point.y-center.y), 2))
                     *cosf(sector.centerAngle-curAngle)) - _beginningDragDistance;
        if (x > 150 || x < -150) x = 150 * fabs(x)/x;
        x = 17 * (2*(fabs(x)/150)-powf((fabs(x)/150), 2))
        *(fabs(x)/x);
        
        [layer addDraggingSpringAnimationWithAmplitude:x
                                                 delay:0
                                              delegate:self];
        
        if ([_parentView.delegate respondsToSelector:@selector(pieChartView:didSelectedSectorAtIndex:)]) {
            [_parentView.delegate pieChartView:_parentView didSelectedSectorAtIndex:_draggedIndex];
        }
    }
}

@end
