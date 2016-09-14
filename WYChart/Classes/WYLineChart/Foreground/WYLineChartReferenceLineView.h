//
//  WYLineChartReferenceLineView.h
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYLineChartView.h"

@interface WYLineChartReferenceLineView : UIView

@property (nonatomic, weak) WYLineChartView *parentView;

@property (nonatomic, copy) UIColor *averageLineColor;
@property (nonatomic, copy) UIColor *verticalReferenceLineColor;
@property (nonatomic, copy) UIColor *horizontalRefernenceLineColor;
@property (nonatomic, copy) UIColor *touchReferenceLineColor;

@property (nonatomic) CGFloat averageLineWidth;
@property (nonatomic) CGFloat verticalReferenceLineWidth;
@property (nonatomic) CGFloat horizontalReferenceLineWidth;
@property (nonatomic) CGFloat touchReferenceLineWidth;

@property (nonatomic) CGFloat averageLineAlpha;
@property (nonatomic) CGFloat verticalReferenceLineAlpha;
@property (nonatomic) CGFloat horizontalReferenceLineAlpha;
@property (nonatomic) CGFloat touchReferenceLineAlpha;

/**
 *	if nil, a line without dash
 *  如果为空，则为实线
 */
@property (nonatomic, copy) NSArray *averageLineDashPattern;
@property (nonatomic, copy) NSArray *verticalReferenceLineDashPattern;
@property (nonatomic, copy) NSArray *horizontalReferenceLineDashPattern;
@property (nonatomic, copy) NSArray *touchReferenceLineDashPattern;

@property (nonatomic) WYLineChartAnimationStyle animationStyle;
@property (nonatomic) CGFloat animationDuration;

- (void)moveReferenceLineToPoint:(CGPoint)point;

- (void)dismissReferenceLine;

@end

@interface WYLineChartVerticalReferenceLineView : WYLineChartReferenceLineView

@end

@interface WYLineChartHorizontalReferenceLineView : WYLineChartReferenceLineView

@end