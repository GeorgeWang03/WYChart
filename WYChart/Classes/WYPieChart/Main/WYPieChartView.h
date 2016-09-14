//
//  WYPieChartView.h
//  WYChart
//
//  Created by yingwang on 16/8/13.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WYPieChartView;
@class WYPieChartCalculator;

typedef NS_ENUM(NSUInteger, WYPieChartStyle) {
    
    kWYPieChartNormalStyle,
    
    kWYPieChartGearStyle
};

typedef NS_ENUM(NSUInteger, WYPieChartSectorSelectedStyle) {
    
    kWYPieChartSectorSelectedExtraction,
    
    kWYPieChartSectorSelectedPull,
    
    kWYPieChartSectorSelectedNone
};

typedef NS_ENUM(NSUInteger, WYPieChartAnimationStyle) {
    
    kWYPieChartAnimationOrderlySpreading,
    
    kWYPieChartAnimationAllSpreading,
    
    kWYPieChartAnimationStretching,
    
    kWYPieChartAnimationAlpha,
    
    kWYPieChartAnimationScale,
    
    kWYPieChartAnimationNone
};

@protocol WYPieChartViewDelegate <NSObject>

@optional
- (NSInteger)numberOfLabelOnPieChartView:(WYPieChartView *)pieChartView;

- (void)pieChartView:(WYPieChartView *)pieChartView didSelectedSectorAtIndex:(NSInteger)index;

@end

@protocol  WYPieChartViewDatasource <NSObject>
@required

- (UIColor *)pieChartView:(WYPieChartView *)pieChartView sectorColorAtIndex:(NSInteger)index;

@optional
- (NSInteger)pieChartView:(WYPieChartView *)pieChartView valueIndexReferToLabelAtIndex:(NSInteger)index;

- (NSString *)pieChartView:(WYPieChartView *)pieChartView textForLabelAtIndex:(NSInteger)index;



@end

@interface WYPieChartView : UIView

@property (nonatomic, copy) NSArray *values;

@property (nonatomic, weak) id<WYPieChartViewDelegate> delegate;
@property (nonatomic, weak) id<WYPieChartViewDatasource> datasource;

@property (nonatomic, strong) WYPieChartCalculator *calculator;

///////--------------------------------------- Animation ------------------------------------------///////

@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) WYPieChartAnimationStyle animationStyle;

@property (nonatomic) WYPieChartStyle style;

///////--------------------------------------- Interact ------------------------------------------///////

@property (nonatomic) BOOL rotatable;
@property (nonatomic) WYPieChartSectorSelectedStyle selectedStyle;

///////--------------------------------------- Attributes ------------------------------------------///////

@property (nonatomic) BOOL showInnerCircle;

@property (nonatomic, copy) UIColor *sectorStrokeColor;

@property (nonatomic) CGFloat sectorLineWidth;

@property (nonatomic) BOOL fillByGradient;

@property (nonatomic, strong) UIColor *labelsTextColor;
@property (nonatomic, strong) UIColor *labelsBackgroundColor;

- (void)update;

@end
