//
//  WYLineChartCategory.h
//  WYChart
//
//  Created by yingwang on 16/8/13.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UIView (WYChart)

@property (nonatomic, readonly) CGFloat wy_boundsWidth;
@property (nonatomic, readonly) CGFloat wy_boundsHeight;
@property (nonatomic, readonly) CGFloat wy_originX;
@property (nonatomic, readonly) CGFloat wy_originY;
@property (nonatomic, readonly) CGPoint wy_boundsCenter;
@property (nonatomic, readonly) CGFloat wy_maxX;
@property (nonatomic, readonly) CGFloat wy_maxY;

- (CGPoint)wy_centerForPresentationLayer:(BOOL)isPresentationLayer;
- (CGFloat)wy_rotateAngleForPresentationLayer:(BOOL)isPresentationLayer;

@end

@interface CALayer (WYChart)

- (CGPoint)wy_centerForPresentationLayer:(BOOL)isPresentationLayer; 
- (CGFloat)wy_transformScaleForPresentationLayer:(BOOL)isPresentationLayer;
@end

@interface UIColor (WYChart)

- (NSArray *)wy_rgbValue;
+ (UIColor *)wy_colorWithHexString:(NSString *)str;
+ (UIColor *)wy_colorWithHex:(UInt32)color;
+ (UIColor *)wy_colorWithHex:(UInt32)color alpha:(CGFloat)alpha;

@end

@interface UIImage (WYChart)
+ (UIImage *)imageFromColor:(UIColor *)color;
@end
