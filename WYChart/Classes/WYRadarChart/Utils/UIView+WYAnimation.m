//
//  UIView+WYAnimation.m
//  WYChart
//
//  Created by Allen on 08/01/2017.
//  Copyright © 2017 FreedomKing. All rights reserved.
//

#import "UIView+WYAnimation.h"
#import <objc/runtime.h>
#import "YYWeakProxy.h"

#define kWYScaleSpringLayerKey  @"kWYScaleSpringLayerKey"

@interface WYUIViewAnimationDelegate : NSObject <CAAnimationDelegate>

@end

@implementation WYUIViewAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    CALayer *layer = [anim valueForKeyPath:kWYScaleSpringLayerKey];
    if (layer) {
        layer.opacity = 1.0;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CALayer *layer = [anim valueForKeyPath:kWYScaleSpringLayerKey];
    if (layer) {
        [anim setValue:nil forKeyPath:kWYScaleSpringLayerKey];
    }
}

@end

@interface UIView()

@property (nonatomic, strong) WYUIViewAnimationDelegate *wyViewAnimationDelegate;

@end

@implementation UIView(WYAnimation)

- (WYUIViewAnimationDelegate *)wyViewAnimationDelegate {
    return objc_getAssociatedObject(self, @selector(wyViewAnimationDelegate));
}

- (void)setWyViewAnimationDelegate:(WYUIViewAnimationDelegate *)wyViewAnimationDelegate {
    objc_setAssociatedObject(self, @selector(wyViewAnimationDelegate), wyViewAnimationDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)wy_addScaleSpringWithDelay:(CGFloat)delay reverse:(BOOL)isReverse {
    if (!self.wyViewAnimationDelegate) {
        self.wyViewAnimationDelegate = [WYUIViewAnimationDelegate new];
    }
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
    groundAnimation.delegate = self.wyViewAnimationDelegate;
    groundAnimation.beginTime = CACurrentMediaTime() + delay;
    
    [groundAnimation setValue:self.layer forKey:kWYScaleSpringLayerKey];
    
    [self.layer addAnimation:groundAnimation forKey:nil];
}

@end
