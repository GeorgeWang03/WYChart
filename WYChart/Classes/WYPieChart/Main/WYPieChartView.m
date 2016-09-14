//
//  WYPieChartView.m
//  WYChart
//
//  Created by yingwang on 16/8/13.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYPieChartView.h"
#import "WYMainPieChartView.h"
#import "WYChartCategory.h"
#import "WYPieChartForegroundView.h"
#import "WYPieChartCalculator.h"

#define DEFAULT_PIE_CHART_MARGIN 50

#define DEFAULT_ANIMATION_DURATION 2

#define DEFAULT_LABELS_TEXT_COLOR [UIColor darkGrayColor]
#define DEFAULT_LABELS_BACKGROUND_COLOR [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0]

@interface WYPieChartView ()

@property (nonatomic, strong) WYMainPieChartView *pieView;
@property (nonatomic, strong) WYPieChartForegroundView *foregroundView;

@property (nonatomic, strong) NSArray *sectors;

@end

@implementation WYPieChartView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initializeProperty];
        [self initiliazeComponent];
    }
    
    return self;
}

- (void)initializeProperty {
    
    _calculator = [[WYPieChartCalculator alloc] init];
    
    _animationDuration = DEFAULT_ANIMATION_DURATION;
    
    _fillByGradient = true;
    _rotatable = true;
    
    _labelsTextColor = DEFAULT_LABELS_TEXT_COLOR;
    _labelsBackgroundColor = DEFAULT_LABELS_BACKGROUND_COLOR;
}

- (void)initiliazeComponent {
    
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    
    //* * * * * * * * * * * * * * * * * * * *//
    //     Initialize   Main Pie View        //
    //* * * * * * * * * * * * * * * * * * * *//
    
    CGRect frame = CGRectMake(0, 0, fmaxf(boundsWidth, boundsHeight) - DEFAULT_PIE_CHART_MARGIN, fmaxf(boundsWidth, boundsHeight) - DEFAULT_PIE_CHART_MARGIN);
    _pieView = [[WYMainPieChartView alloc] initWithFrame:frame];
    _pieView.center = self.wy_boundsCenter;
    _pieView.backgroundColor = [UIColor clearColor];
    _pieView.parentView = self;
    
    [self addSubview:_pieView];
    
    _foregroundView = [[WYPieChartForegroundView alloc] initWithFrame:self.bounds];
    _foregroundView.userInteractionEnabled = false;
    _foregroundView.backgroundColor = [UIColor clearColor];
    _foregroundView.parentView = self;
    [self addSubview:_foregroundView];
}

#pragma mark - setter and getter

- (void)setDelegate:(id<WYPieChartViewDelegate>)delegate {
    
    _delegate = delegate;
}

#pragma mark - Update Operation
- (void)update {
    
    _sectors = [_calculator createSectorsForValues:_values
                                           atPoint:_pieView.wy_boundsCenter
                                            radius:_pieView.sectorsRadius
                                            pieStyle:_style
                                   showInnerCircle:_showInnerCircle];
    
    _pieView.sectors = _sectors;
    _pieView.strokeColor = _sectorStrokeColor;
    _pieView.lineWidth = _sectorLineWidth;
    _pieView.style = _style;
    _pieView.animationStyle = _animationStyle;
    _pieView.animationDuration = _animationDuration;
    _pieView.fillByGradient = _fillByGradient;
    _pieView.showInnerCircle = _showInnerCircle;
    
    _pieView.rotatabel = _rotatable;
    _pieView.draggable = _selectedStyle == kWYPieChartSectorSelectedPull;
    _pieView.selectable = _selectedStyle == kWYPieChartSectorSelectedExtraction;
    
    [_pieView setNeedsDisplay];
    
    _foregroundView.sectors = _sectors;
    _foregroundView.alpha = 0;
    _foregroundView.labelsTextColor = _labelsTextColor;
    _foregroundView.labelsBackgroundColor = _labelsBackgroundColor;
    if (_animationStyle == kWYPieChartAnimationNone) _foregroundView.alpha = 1;
    [_foregroundView reloadData];
}

- (void)chartRotateAngle:(CGFloat)angle {
    
    [_foregroundView updateWithRotateAngle:angle];
}

- (void)chartAnimationDidStop {
    [UIView animateWithDuration:1.0
                     animations:^{
                         _foregroundView.alpha = 1;
                     }];
}

@end
