//
//  WYLineChartDefine.h
//  Pods
//
//  Created by yingwang on 2016/11/18.
//
//


#ifndef WYLineChartDefine_h
#define WYLineChartDefine_h

FOUNDATION_EXTERN NSString * const kWYLineChartLineAttributeLineWidth;
FOUNDATION_EXTERN NSString * const kWYLineChartLineAttributeLineStyle;
FOUNDATION_EXTERN NSString * const kWYLineChartLineAttributeLineColor;
FOUNDATION_EXTERN NSString * const kWYLineChartLineAttributeLineDashPattern;

FOUNDATION_EXTERN NSString * const kWYLineChartLineAttributeDrawGradient;

FOUNDATION_EXTERN NSString * const kWYLineChartLineAttributeShowJunctionShape;
FOUNDATION_EXTERN NSString * const kWYLineChartLineAttributeJunctionColor;
FOUNDATION_EXTERN NSString * const kWYLineChartLineAttributeJunctionStyle;
FOUNDATION_EXTERN NSString * const kWYLineChartLineAttributeJunctionSize;

typedef NS_ENUM(NSUInteger, WYLineChartAnimationStyle) {
    
    kWYLineChartAnimationDrawing,
    kWYLineChartAnimationAlpha,
    kWYLineChartAnimationWidth,
    kWYLineChartAnimationRise,
    kWYLineChartAnimationSpring,
    kWYLineChartNoneAnimation
};

typedef NS_ENUM(NSUInteger, WYLineChartMainLineStyle) {
    
    kWYLineChartMainStraightLine,
    
    kWYLineChartMainBezierWaveLine,
    
    kWYLineChartMainBezierTaperLine,
    
    kWYLineChartMainNoneLine
};

typedef NS_OPTIONS(NSUInteger, WYLineChartViewScaleOption) {
    
    kWYLineChartViewScaleNarrow = 1 << 0,
    
    kWYLineChartViewScaleLarge = 1 << 1,
    
    kWYLineChartViewScaleNoChange = 1 << 2
};


@class WYLineChartView;
@class WYLineChartPoint;
@class WYLineChartCalculator;

@protocol WYLineChartViewDelegate <NSObject>

@required

- (CGFloat)gapBetweenPointsHorizontalInLineChartView:(WYLineChartView *)chartView;

@optional

- (NSInteger)numberOfLabelOnXAxisInLineChartView:(WYLineChartView *)chartView;

- (NSInteger)numberOfLabelOnYAxisInLineChartView:(WYLineChartView *)chartView;

- (NSInteger)numberOfReferenceLineVerticalInLineChartView:(WYLineChartView *)chartView;

- (NSInteger)numberOfReferenceLineHorizontalInLineChartView:(WYLineChartView *)chartView;

- (void)lineChartView:(WYLineChartView *)lineView didBeganTouchAtSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value;

- (void)lineChartView:(WYLineChartView *)lineView didMovedTouchToSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value;

- (void)lineChartView:(WYLineChartView *)lineView didEndedTouchToSegmentOfPoint:(WYLineChartPoint *)originalPoint value:(CGFloat)value;

- (void)lineChartView:(WYLineChartView *)lineView didBeganPinchWithScale:(CGFloat)scale;

- (void)lineChartView:(WYLineChartView *)lineView didChangedPinchWithScale:(CGFloat)scale;

- (void)lineChartView:(WYLineChartView *)lineView didEndedPinchGraphWithOption:(WYLineChartViewScaleOption)option scale:(CGFloat)scale;

@end

@protocol WYLineChartViewDatasource <NSObject>

@required

- (NSString *)lineChartView:(WYLineChartView *)chartView contentTextForXAxisLabelAtIndex:(NSInteger)index;

- (NSString *)lineChartView:(WYLineChartView *)chartView contentTextForYAxisLabelAtIndex:(NSInteger)index;

@optional
/*
 * v0.2.0
 *  use for custom label text for points, if not implemented or returning nil, label will hidden.
 *  indexPath   indexPath.section means line index, indexPath.row means points index
 */
- (NSString *)lineChartView:(WYLineChartView *)chartView contextTextForPointAtIndexPath:(NSIndexPath *)indexPath;

- (NSDictionary *)lineChartView:(WYLineChartView *)chartView attributesForLineAtIndex:(NSUInteger)index;

- (WYLineChartPoint *)lineChartView:(WYLineChartView *)chartView pointReferToXAxisLabelAtIndex:(NSInteger)index;

- (CGFloat)lineChartView:(WYLineChartView *)chartView valueReferToYAxisLabelAtIndex:(NSInteger)index;

- (WYLineChartPoint *)lineChartView:(WYLineChartView *)chartView pointReferToVerticalReferenceLineAtIndex:(NSInteger)index;

- (CGFloat)lineChartView:(WYLineChartView *)chartView valueReferToHorizontalReferenceLineAtIndex:(NSInteger)index;

@end

#endif /* WYLineChartDefine_h */
