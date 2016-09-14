//
//  WYLineChartCategory.m
//  WYChart
//
//  Created by yingwang on 16/8/13.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYChartCategory.h"

@implementation UIView (WYChart)

- (CGPoint)wy_centerForPresentationLayer:(BOOL)isPresentationLayer {
    
    if (isPresentationLayer) {
        return ((CALayer *)self.layer.presentationLayer).position;
    }
    return self.center;
}

- (CGFloat)wy_rotateAngleForPresentationLayer:(BOOL)isPresentationLayer {
    
    if (isPresentationLayer) {
        return [[((CALayer *)self.layer.presentationLayer) valueForKeyPath:@"transform.rotation.z"] floatValue];
    }
    return [[self.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
}

- (CGFloat)wy_originX {
    
    return CGRectGetMinX(self.frame);
}

- (CGFloat)wy_originY {
    return CGRectGetMinY(self.frame);
}

- (CGFloat)wy_boundsWidth {
    return CGRectGetWidth(self.bounds);
}

- (CGFloat)wy_boundsHeight {
    return CGRectGetHeight(self.bounds);
}

- (CGPoint)wy_boundsCenter {
    return CGPointMake(self.wy_boundsWidth/2, self.wy_boundsHeight/2);
}

@end

@implementation CALayer (WYChart)

- (CGPoint)wy_centerForPresentationLayer:(BOOL)isPresentationLayer {
    
    if (isPresentationLayer) {
        return ((CALayer *)self.presentationLayer).position;
    }
    return self.position;
}

- (CGFloat)wy_transformScaleForPresentationLayer:(BOOL)isPresentationLayer {
    
    if (isPresentationLayer) {
        return [[((CALayer *)self.presentationLayer) valueForKeyPath:@"transform.scale.x"] floatValue];
    }
    return [[self valueForKeyPath:@"transform.scale.x"] floatValue];
}

@end

@implementation UIColor (WYChart)

- (NSArray *)wy_rgbValue {
    
    const CGFloat* colors = CGColorGetComponents( self.CGColor );
    return [NSArray arrayWithObjects:@(colors[0]), @(colors[1]), @(colors[2]), @(colors[3]), nil];
}

+ (UIColor *)wy_colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [UIColor wy_colorWithHex:x];
}

// takes 0x123456
+ (UIColor *)wy_colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}


@end

@implementation UIImage (WYChart)

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end