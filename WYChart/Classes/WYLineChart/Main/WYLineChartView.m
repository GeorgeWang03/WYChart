//
//  WYLineChartView.m
//  WYChart
//
//  Created by yingwang on 16/8/6.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYLineChartView.h"
#import "WYLineChartPoint.h"
#import "WYLineChartCalculator.h"
#import "WYLineChartCoordinateView.h"
#import "WYLineChartMainLineView.h"
#import "WYLineChartReferenceLineView.h"

///////--------------------------------------- Reference Line Default Attribute ------------------------------------------///////

#define DEFAULT_BACKGROUND_COLOR [UIColor colorWithRed:12.f/255.f green:71.f/255.f blue:98.f/255.f alpha:0.9]
#define DEFAULT_AXIS_COLOR [UIColor whiteColor]

#define DEFAULT_LABEL_COLOR [UIColor whiteColor]

#define DEFAULT_LINE_COLOR [UIColor whiteColor]
#define DEFAULT_LINE_WIDTH 2.f
#define DEFAULT_LINE_DASHPATTERN nil

#define DEFAULT_GRADIENT_COLORS @[[UIColor colorWithWhite:1.0 alpha:0.9], [UIColor colorWithWhite:1.0 alpha:0.0]]
#define DEFAULT_GRADIENT_LOCATION  @[@(0.0), @(0.95)]

#define DEFAULT_VERTICAL_REFERENCELINE_COLOR [UIColor whiteColor]
#define DEFAULT_VERTICAL_REFERENCELINE_WIDTH 1.0
#define DEFAULT_VERTICAL_REFERENCELINE_ALPHA 0.6
#define DEFAULT_VERTICAL_REFERENCELINE_DASHPARTTEN nil

#define DEFAULT_HORIZONTAL_REFERENCELINE_COLOR [UIColor whiteColor]
#define DEFAULT_HORIZONTAL_REFERENCELINE_WIDTH 1.0
#define DEFAULT_HORIZONTAL_REFERENCELINE_ALPHA 0.6
#define DEFAULT_HORIZONTAL_REFERENCELINE_DASHPARTTEN @[@2, @2]

#define DEFAULT_AVERAGE_REFERENCELINE_COLOR [UIColor blackColor]
#define DEFAULT_AVERAGE_REFERENCELINE_WIDTH 2.0
#define DEFAULT_AVERAGE_REFERENCELINE_ALPHA 0.6
#define DEFAULT_AVERAGE_REFERENCELINE_DASHPARTTEN @[@2, @2]

#define DEFAULT_TOUCH_REFERENCELINE_COLOR [UIColor brownColor]
#define DEFAULT_TOUCH_REFERENCELINE_WIDTH 1.0
#define DEFAULT_TOUCH_REFERENCELINE_ALPHA 0.8
#define DEFAULT_TOUCH_REFERENCELINE_DASHPARTTEN @[@2, @2]

#define DEFAULT_SHOW_JUNCTION_SHAPE true
#define DEFAULT_JUNCTION_COLOR [UIColor whiteColor]
#define DEFAULT_JUNCTION_POINT_STYLE kWYLineChartJunctionShapeSolidCircle
#define DEFAULT_JUNCTION_POINT_SIZE kWYLineChartJunctionSmallShape

#define DEFAULT_TOUCH_POINT_COLOR [UIColor whiteColor]
#define DEFAULT_TOUCH_POINT_STYLE kWYLineChartJunctionShapeSolidCircle
#define DEFAULT_TOUCH_POINT_SIZE kWYLineChartJunctionSmallShape

#define DEFAULT_ANIMATION_STYLE kWYLineChartAnimationDrawing
#define DEFAULT_ANIMATION_DUIRATION 2.0

#define DEFAULT_LINE_LEFT_MARGIN 10
#define DEFAULT_LINE_RIGHT_MARGIN 10
#define DEFAULT_LINE_TOP_MARGIN 20
#define DEFAULT_LINE_BOTTOM_MARGIN 50

@interface WYLineChartView () <UIScrollViewDelegate,
                               WYLineChartMainLineViewDelegate>
{
    WYLineChartCalculator *_calculator;
}

@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) WYLineChartMainLineView *lineGraph;
@property (nonatomic, strong) WYLineChartVerticalReferenceLineView *verticalReferenceLineGraph;
@property (nonatomic, strong) WYLineChartHorizontalReferenceLineView *horizontalReferenceLineGraph;

@property (nonatomic, strong) WYLineChartCoordinateXAXisView * xAxisView;
@property (nonatomic, strong) WYLineChartCoordinateYAXisView * yAxisView;

@property (nonatomic, strong) UIView *pinchView;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@property (nonatomic) BOOL respondToPinchBeginMethor;
@property (nonatomic) BOOL respondToPinchChangeBeginMethor;
@property (nonatomic) BOOL respondToPinchEndBeginMethor;

@end

@implementation WYLineChartView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initializeProperty];
        [self initializeComponents];
    }
    
    return self;
}

- (void)initializeProperty {
    
    _calculator = [[WYLineChartCalculator alloc] init];
    _calculator.parentView = self;
    
    //* * * * * * * * * * * * * * * * * * * *//
    //                  Value                //
    //* * * * * * * * * * * * * * * * * * * *//
    _scrollable = YES;
    _drawGradient = YES;
    
    //* * * * * * * * * * * * * * * * * * * *//
    //                  Rect                 //
    //* * * * * * * * * * * * * * * * * * * *//
    
    //* * * * * * * * * * * * * * * * * * * *//
    //                Color                  //
    //* * * * * * * * * * * * * * * * * * * *//
    self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    _labelsColor = DEFAULT_LABEL_COLOR;
    _axisColor = DEFAULT_AXIS_COLOR;
    _gradientColors = DEFAULT_GRADIENT_COLORS;
    _gradientColorsLocation = DEFAULT_GRADIENT_LOCATION;
    
    //* * * * * * * * * * * * * * * * * * * *//
    //                Attributes             //
    //* * * * * * * * * * * * * * * * * * * *//
    
    _animationStyle = DEFAULT_ANIMATION_STYLE;
    _animationDuration = DEFAULT_ANIMATION_DUIRATION;
    
    _labelsFont = [UIFont systemFontOfSize:11.f weight:0.5];
    
    _lineColor = DEFAULT_LINE_COLOR;
    _lineWidth = DEFAULT_LINE_WIDTH;
    _lineDashPattern = DEFAULT_LINE_DASHPATTERN;
    
    _verticalReferenceLineColor = DEFAULT_VERTICAL_REFERENCELINE_COLOR;
    _verticalReferenceLineWidth = DEFAULT_VERTICAL_REFERENCELINE_WIDTH;
    _verticalReferenceLineAlpha = DEFAULT_VERTICAL_REFERENCELINE_ALPHA;
    _verticalReferenceLineDashPattern = DEFAULT_VERTICAL_REFERENCELINE_DASHPARTTEN;
    
    _horizontalRefernenceLineColor = DEFAULT_HORIZONTAL_REFERENCELINE_COLOR;
    _horizontalReferenceLineWidth = DEFAULT_HORIZONTAL_REFERENCELINE_WIDTH;
    _horizontalReferenceLineAlpha = DEFAULT_HORIZONTAL_REFERENCELINE_ALPHA;
    _horizontalReferenceLineDashPattern = DEFAULT_HORIZONTAL_REFERENCELINE_DASHPARTTEN;
    
    _averageLineColor = DEFAULT_AVERAGE_REFERENCELINE_COLOR;
    _averageLineWidth = DEFAULT_AVERAGE_REFERENCELINE_WIDTH;
    _averageLineAlpha = DEFAULT_AVERAGE_REFERENCELINE_ALPHA;
    _averageLineDashPattern = DEFAULT_AVERAGE_REFERENCELINE_DASHPARTTEN;
    
    _touchReferenceLineColor = DEFAULT_TOUCH_REFERENCELINE_COLOR;
    _touchReferenceLineWidth = DEFAULT_TOUCH_REFERENCELINE_WIDTH;
    _touchReferenceLineAlpha = DEFAULT_TOUCH_REFERENCELINE_ALPHA;
    _touchReferenceLineDashPattern = DEFAULT_TOUCH_REFERENCELINE_DASHPARTTEN;
    
    _showJunctionShape = DEFAULT_SHOW_JUNCTION_SHAPE;
    _junctionColor = DEFAULT_JUNCTION_COLOR;
    _junctionStyle = DEFAULT_JUNCTION_POINT_STYLE;
    _junctionSize = DEFAULT_JUNCTION_POINT_SIZE;
    _touchPointColor = DEFAULT_TOUCH_POINT_COLOR;
    _touchPointStyle = DEFAULT_TOUCH_POINT_STYLE;
    _touchPointSize = DEFAULT_TOUCH_POINT_SIZE;
    
    _lineLeftMargin = DEFAULT_LINE_LEFT_MARGIN;
    _lineRightMargin = DEFAULT_LINE_RIGHT_MARGIN;
    _lineTopMargin = DEFAULT_LINE_TOP_MARGIN;
    _lineBottomMargin = DEFAULT_LINE_BOTTOM_MARGIN;
}

- (void)initializeComponents {
    
    CGRect frame;
    CGFloat x, y;
    CGFloat height;
    CGFloat width;
    
    //* * * * * * * * * * * * * * * * * * * * *//
    //             configure Y axis            //
    //* * * * * * * * * * * * * * * * * * * * *//
    
    height = CGRectGetHeight(self.bounds);
    frame = CGRectMake(0, 0, _calculator.yAxisViewWidth, height);
    _yAxisView = [[WYLineChartCoordinateYAXisView alloc] initWithFrame:frame];
    _yAxisView.parentView = self;
    _yAxisView.backgroundColor = [UIColor clearColor];
    [self addSubview:_yAxisView];
    
    
    //* * * * * * * * * * * * * * * * * * * * *//
    //             configure X axis            //
    //* * * * * * * * * * * * * * * * * * * * *//
    
    height = _calculator.xAxisLabelHeight + 2;
    y = CGRectGetHeight(self.bounds) - height;
    x = CGRectGetMaxX(_yAxisView.frame);
    width = _calculator.drawableAreaWidth;
    frame = CGRectMake(x, y, width, height);
    _xAxisView = [[WYLineChartCoordinateXAXisView alloc] initWithFrame:frame];
    _xAxisView.parentView = self;
    _xAxisView.backgroundColor = [UIColor clearColor];
    
    
    //* * * * * * * * * * * * * * * * * * * *//
    //       configure scroll view           //
    //* * * * * * * * * * * * * * * * * * * *//
    
    x = CGRectGetMaxX(_yAxisView.frame);
    height = CGRectGetHeight(self.bounds);
    y = 0;
    width = _calculator.lineGraphWindowWidth;
    frame = CGRectMake(x, y, width, height);
    _contentScrollView = [[UIScrollView alloc] initWithFrame:frame];
    _contentScrollView.delegate = self;
    _contentScrollView.showsHorizontalScrollIndicator = false;
    _contentScrollView.showsVerticalScrollIndicator = false;
    [self addSubview:_contentScrollView];
    [_contentScrollView addSubview:_xAxisView];
    
    //* * * * * * * * * * * * * * * * * * * *//
    //        configure reference line       //
    //* * * * * * * * * * * * * * * * * * * *//
    
    frame = CGRectMake(0, 0, _contentScrollView.contentSize.width, _calculator.drawableAreaHeight);
    _verticalReferenceLineGraph = [[WYLineChartVerticalReferenceLineView alloc] initWithFrame:frame];
    _verticalReferenceLineGraph.backgroundColor = [UIColor clearColor];
    _verticalReferenceLineGraph.parentView = self;
    
    [_contentScrollView addSubview:_verticalReferenceLineGraph];
    
    frame = CGRectMake(CGRectGetMaxX(_yAxisView.frame), 0, _calculator.lineGraphWindowWidth, _calculator.drawableAreaHeight);
    _horizontalReferenceLineGraph = [[WYLineChartHorizontalReferenceLineView alloc] initWithFrame:frame];
    _horizontalReferenceLineGraph.backgroundColor = [UIColor clearColor];
    _horizontalReferenceLineGraph.parentView = self;
    
    [self insertSubview:_horizontalReferenceLineGraph belowSubview:_contentScrollView];
    
    //* * * * * * * * * * * * * * * * * * * * *//
    //          configure pinch view           //
    //* * * * * * * * * * * * * * * * * * * * *//
    frame = CGRectZero;
    frame.size = _contentScrollView.contentSize;
    frame.size.height = _calculator.drawableAreaHeight;
    _pinchView = [[UIView alloc] initWithFrame:frame];
    _pinchView.backgroundColor = [UIColor clearColor];
    [self setupPinchGesture];
    
    [_contentScrollView addSubview:_pinchView];
    
    //* * * * * * * * * * * * * * * * * * * *//
    //        configure line shape           //
    //* * * * * * * * * * * * * * * * * * * *//
    frame = CGRectZero;
    frame.size = _contentScrollView.contentSize;
    frame.size.height = _calculator.drawableAreaHeight;
    _lineGraph = [[WYLineChartMainLineView alloc] initWithFrame:frame];
    _lineGraph.parentView = self;
    _lineGraph.backgroundColor = [UIColor clearColor];
    [_pinchView addSubview:_lineGraph];
}

- (void)updateGraph {
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"hh:mm:ss";
//    NSLog(@" begin %@", [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:[NSDate timeIntervalSinceReferenceDate]]]);
    
    // recalculate points coordinate
    [_calculator recaclculatePointsCoordinate];
    _lineGraph.pathSegments = [_calculator recalculatePathSegmentsForPoints:_points withLineStyle:_lineStyle];
    
    CGRect frame;
    CGFloat x, y;
    CGFloat height;
    CGFloat width;
    
    //* * * * * * * * * * * * * * * * * * * * *//
    //              reset Y axis               //
    //* * * * * * * * * * * * * * * * * * * * *//
    
    height = CGRectGetHeight(self.bounds);
    frame = CGRectMake(0, 0, _calculator.yAxisViewWidth, height);
    _yAxisView.frame = frame;
    [_yAxisView setNeedsDisplay];
    
    //* * * * * * * * * * * * * * * * * * * * *//
    //                 reset X axis            //
    //* * * * * * * * * * * * * * * * * * * * *//
    
    height = _calculator.xAxisLabelHeight + 2;
    y = CGRectGetHeight(self.bounds) - height;
    x = 0;
    width = _calculator.drawableAreaWidth;
    frame = CGRectMake(x, y, width, height);
    _xAxisView.frame = frame;
    [_xAxisView setNeedsDisplay];
    
    //* * * * * * * * * * * * * * * * * * * *//
    //           reset scroll view           //
    //* * * * * * * * * * * * * * * * * * * *//
    
    x = CGRectGetMaxX(_yAxisView.frame);
    height = CGRectGetHeight(self.bounds);
    y = 0;
    width = _calculator.lineGraphWindowWidth;
    frame = CGRectMake(x, y, width, height);
    _contentScrollView.frame = frame;
    _contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(_xAxisView.frame), CGRectGetHeight(_contentScrollView.bounds));

    
    //* * * * * * * * * * * * * * * * * * * *//
    //           reset reference line        //
    //* * * * * * * * * * * * * * * * * * * *//
    
    _verticalReferenceLineGraph.verticalReferenceLineColor = _verticalReferenceLineColor;
    _verticalReferenceLineGraph.verticalReferenceLineWidth = _verticalReferenceLineWidth;
    _verticalReferenceLineGraph.verticalReferenceLineAlpha = _verticalReferenceLineAlpha;
    _verticalReferenceLineGraph.verticalReferenceLineDashPattern = _verticalReferenceLineDashPattern;
    
    _verticalReferenceLineGraph.touchReferenceLineColor = _touchReferenceLineColor;
    _verticalReferenceLineGraph.touchReferenceLineWidth = _touchReferenceLineWidth;
    _verticalReferenceLineGraph.touchReferenceLineAlpha = _touchReferenceLineAlpha;
    _verticalReferenceLineGraph.touchReferenceLineDashPattern = _touchReferenceLineDashPattern;
    
    _horizontalReferenceLineGraph.horizontalRefernenceLineColor = _horizontalRefernenceLineColor;
    _horizontalReferenceLineGraph.horizontalReferenceLineWidth = _horizontalReferenceLineWidth;
    _horizontalReferenceLineGraph.horizontalReferenceLineAlpha = _horizontalReferenceLineAlpha;
    _horizontalReferenceLineGraph.horizontalReferenceLineDashPattern = _horizontalReferenceLineDashPattern;
    
    _horizontalReferenceLineGraph.averageLineColor = _averageLineColor;
    _horizontalReferenceLineGraph.averageLineWidth = _averageLineWidth;
    _horizontalReferenceLineGraph.averageLineAlpha = _averageLineAlpha;
    _horizontalReferenceLineGraph.averageLineDashPattern = _averageLineDashPattern;
    
    _horizontalReferenceLineGraph.touchReferenceLineColor = _touchReferenceLineColor;
    _horizontalReferenceLineGraph.touchReferenceLineWidth = _touchReferenceLineWidth;
    _horizontalReferenceLineGraph.touchReferenceLineAlpha = _touchReferenceLineAlpha;
    _horizontalReferenceLineGraph.touchReferenceLineDashPattern = _touchReferenceLineDashPattern;
    
    _verticalReferenceLineGraph.animationStyle = _animationStyle;
    _verticalReferenceLineGraph.animationDuration = _animationDuration;
    _horizontalReferenceLineGraph.animationStyle = _animationStyle;
    _horizontalReferenceLineGraph.animationDuration = _animationDuration;
    
    frame = CGRectMake(0, 0, _contentScrollView.contentSize.width, _calculator.drawableAreaHeight);
    _verticalReferenceLineGraph.frame = frame;
    [_verticalReferenceLineGraph setNeedsDisplay];
    
    frame = CGRectMake(CGRectGetMaxX(_yAxisView.frame), 0, _calculator.lineGraphWindowWidth, _calculator.drawableAreaHeight);
    _horizontalReferenceLineGraph.frame = frame;
    [_horizontalReferenceLineGraph setNeedsDisplay];
    
    
    //* * * * * * * * * * * * * * * * * * * *//
    //      reset pinch view shape           //
    //* * * * * * * * * * * * * * * * * * * *//
    frame = CGRectZero;
    frame.size = _contentScrollView.contentSize;
    frame.size.height = _calculator.drawableAreaHeight;
    _pinchView.frame = frame;
    
    
    //* * * * * * * * * * * * * * * * * * * *//
    //            reset line shape           //
    //* * * * * * * * * * * * * * * * * * * *//
    frame = CGRectZero;
    frame.size = _contentScrollView.contentSize;
    frame.size.height = _calculator.drawableAreaHeight;
    _lineGraph.frame = frame;
    _lineGraph.style = _lineStyle;
    _lineGraph.lineColor = _lineColor;
    _lineGraph.lineWidth = _lineWidth;
    _lineGraph.lineDashPattern = _lineDashPattern;
    _lineGraph.animationStyle = _animationStyle;
    _lineGraph.animationDuration = _animationDuration;
    _lineGraph.junctionColor = _junctionColor;
    _lineGraph.junctionStyle = _junctionStyle;
    _lineGraph.junctionSize = _junctionSize;
    _lineGraph.touchPointColor = _touchPointColor;
    _lineGraph.touchPointStyle = _touchPointStyle;
    _lineGraph.touchPointSize = _touchPointSize;
    _lineGraph.touchView = _touchView;
    _lineGraph.showJunctionShape = _showJunctionShape;
    [_lineGraph setNeedsDisplay];
//    
//    NSLog(@"after %@", [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:[NSDate timeIntervalSinceReferenceDate]]]);
}

#pragma mark - setup and handle pinch gesture

- (void)setupPinchGesture {
    
    _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [_pinchView addGestureRecognizer:_pinchGesture];
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognize {
    
    if (!_pinchable) return;
    
    [self transformComponentsWithPinchScale:recognize.scale];
    if (recognize.state == UIGestureRecognizerStateBegan) {
//        NSLog(@"scale : %f,  state : began", recognize.scale);
        if (_respondToPinchBeginMethor)
            [_delegate lineChartView:self didBeganPinchWithScale:recognize.scale];
    } else if (recognize.state == UIGestureRecognizerStateChanged) {
//        NSLog(@"scale : %f,  state : change", recognize.scale);
        if (_respondToPinchChangeBeginMethor) [_delegate lineChartView:self didChangedPinchWithScale:recognize.scale];
    } else if (recognize.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"scale : %f,  state : end", recognize.scale);
        
        WYLineChartViewScaleOption opt = kWYLineChartViewScaleNoChange;
        if (recognize.scale > 0.7 && recognize.scale < 1.5) {
            [self recoverComponentForPinchCancel];
        } else {
            if (recognize.scale < 0.7) opt = kWYLineChartViewScaleNarrow;
            else opt = kWYLineChartViewScaleLarge;
            [self recoverComponentForPinchConfirm];
            [self updateGraph];
        }
        
        if (_respondToPinchEndBeginMethor)
            [_delegate lineChartView:self didEndedPinchGraphWithOption:opt scale:recognize.scale];
    }
}

- (void)transformComponentsWithPinchScale:(CGFloat)scale {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, scale, 1.0);
    
    CGFloat alpha = scale * 0.3;
    
    _lineGraph.transform = transform;
    _lineGraph.alpha = alpha;
    
    _verticalReferenceLineGraph.transform = transform;
    _verticalReferenceLineGraph.alpha = alpha;

    _xAxisView.transform = transform;
    _xAxisView.alpha = alpha;
    
    _yAxisView.alpha = alpha;
    _horizontalReferenceLineGraph.alpha = alpha;
}

- (void)recoverComponentForPinchConfirm {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1.0, 1.0);
    _lineGraph.transform = transform;
    _lineGraph.alpha = 1.0;
    
    _verticalReferenceLineGraph.transform = transform;
    _verticalReferenceLineGraph.alpha = 1.0;
    
    _xAxisView.transform = transform;
    _xAxisView.alpha = 1.0;
    
    _yAxisView.alpha = 1.0;
    _horizontalReferenceLineGraph.alpha = 1.0;
}
- (void)recoverComponentForPinchCancel {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1.0, 1.0);
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         _lineGraph.transform = transform;
                         _lineGraph.alpha = 1.0;
                         
                         _verticalReferenceLineGraph.transform = transform;
                         _verticalReferenceLineGraph.alpha = 1.0;
                         
                         _xAxisView.transform = transform;
                         _xAxisView.alpha = 1.0;
                         
                         _yAxisView.alpha = 1.0;
                         _horizontalReferenceLineGraph.alpha = 1.0;
                         
                     } completion:nil];
}

#pragma mark - setter and getter

- (WYLineChartCalculator *)calculator {
    return _calculator;
}

- (void)setDelegate:(id<WYLineChartViewDelegate>)delegate {
    
    _delegate = delegate;
    if ([_delegate respondsToSelector:@selector(lineChartView:didBeganPinchWithScale:)])
        _respondToPinchBeginMethor = true;
    else
        _respondToPinchBeginMethor = false;
    
    if ([_delegate respondsToSelector:@selector(lineChartView:didChangedPinchWithScale:)])
        _respondToPinchChangeBeginMethor = true;
    else
        _respondToPinchChangeBeginMethor = false;
    
    if ([_delegate respondsToSelector:@selector(lineChartView:didEndedPinchGraphWithOption:scale:)])
        _respondToPinchEndBeginMethor = true;
    else
        _respondToPinchEndBeginMethor = false;
}

#pragma mark - WYLineChartMainLineViewDelegate

- (void)mainLineView:(WYLineChartMainLineView *)lineView didBeganTouchAtPoint:(CGPoint)point belongToSegmentOfPoint:(WYLineChartPoint *)originalPoint {
//    NSLog(@"touch point : %li", (long)originalPoint.index);
    [_horizontalReferenceLineGraph moveReferenceLineToPoint:point];
    [_verticalReferenceLineGraph moveReferenceLineToPoint:point];
    if ([_delegate respondsToSelector:@selector(lineChartView:didBeganTouchAtSegmentOfPoint:value:)]) {
        [_delegate lineChartView:self didBeganTouchAtSegmentOfPoint:originalPoint value:[_calculator valueReferToVerticalLocation:point.y]];
    }
}

- (void)mainLineView:(WYLineChartMainLineView *)lineView didmovedTouchToPoint:(CGPoint)point belongToSegmentOfPoint:(WYLineChartPoint *)originalPoint {
    
    [_horizontalReferenceLineGraph moveReferenceLineToPoint:point];
    [_verticalReferenceLineGraph moveReferenceLineToPoint:point];
    if ([_delegate respondsToSelector:@selector(lineChartView:didMovedTouchToSegmentOfPoint:value:)]) {
        [_delegate lineChartView:self didMovedTouchToSegmentOfPoint:originalPoint value:[_calculator valueReferToVerticalLocation:point.y]];
    }
}

- (void)mainLineView:(WYLineChartMainLineView *)lineView didEndedTouchAtPoint:(CGPoint)point belongToSegmentOfPoint:(WYLineChartPoint *)originalPoint {
//    NSLog(@"touch point : %li", (long)originalPoint.index);
    [_horizontalReferenceLineGraph dismissReferenceLine];
    [_verticalReferenceLineGraph dismissReferenceLine];
    if ([_delegate respondsToSelector:@selector(lineChartView:didEndedTouchToSegmentOfPoint:value:)]) {
        [_delegate lineChartView:self didEndedTouchToSegmentOfPoint:originalPoint value:[_calculator valueReferToVerticalLocation:point.y]];
    }
}

@end
