//
//  WYRadarShapeLayer.m
//  WYChart
//
//  Created by Allen on 08/01/2017.
//  Copyright © 2017 FreedomKing. All rights reserved.
//

#import "WYRadarChartItemView.h"
#import "WYLineChartJunctionShape.h"
#import "UIView+WYAnimation.h"

@interface WYRadarChartItemView()

@property (nonatomic, strong) WYRadarChartItem *item;
@property (nonatomic, strong) NSArray <NSNumber *> *subPathRatio;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) NSMutableArray <WYLineChartJunctionShape *> *junctions;

@end

@implementation WYRadarChartItemView

- (instancetype)initWithFrame:(CGRect)frame item:(WYRadarChartItem *)item {
    self = [super initWithFrame:frame];
    if (self) {
        _item = item;
        [self setupData];
        [self setupUI];
    }
    return self;
}

- (void)setupData {
    _breakPoints = [NSMutableArray new];
    _junctions = [NSMutableArray new];
}

- (void)setupUI {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.lineWidth = _item.borderWidth;
    layer.fillColor = _item.fillColor.CGColor;
    layer.strokeColor = _item.borderColor.CGColor;
    layer.frame = self.bounds;
    _shapeLayer = layer;
    [self.layer addSublayer:layer];
}

- (void)setBreakPoints:(NSArray *)breakPoints {
    _breakPoints = breakPoints;
    if (breakPoints.count <= 1) {
        return;
    }
    NSMutableArray *pathLength = [NSMutableArray new];
    CGFloat totalLength = 0.0;
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    for (NSInteger index = 0; index < breakPoints.count; index++) {
        startPoint = [breakPoints[index] CGPointValue];
        endPoint = [breakPoints[(index+1)%breakPoints.count] CGPointValue];
        CGFloat length = sqrtf((endPoint.x - startPoint.x)*(endPoint.x - startPoint.x)+
                               (endPoint.y - startPoint.y)*(endPoint.y - startPoint.y));
        totalLength += length;
        [pathLength addObject:@(length)];
    }
    
    for (NSInteger index = 0; index < breakPoints.count; index++) {
        pathLength[index] = @([pathLength[index] floatValue]/totalLength);
    }
    self.subPathRatio = pathLength;
    
    // add junction
    if (self.item.junctionShape == kWYLineChartJunctionShapeNone) {
        return;
    }
    for (NSInteger index = 0; index < breakPoints.count; index++) {
        CGPoint point = [breakPoints[index] CGPointValue];
        WYLineChartJunctionShape *shape = [[WYLineChartJunctionShape alloc] initWithStyle:self.item.junctionShape
                                                                                     size:kWYLineChartJunctionSmallShape
                                                                                   origin:CGPointZero];
        shape.fillColor = self.item.fillColor;
        shape.strokeColor = self.item.borderColor;
        shape.center = point;
        [self.junctions addObject:shape];
        [self addSubview:shape];
    }
}

- (void)startJunctionAnimationWithStyle:(WYRadarChartViewAnimation)animationStyle
                                  delay:(NSTimeInterval)delay
                               duration:(NSTimeInterval)duration {
    if (self.item.junctionShape == kWYLineChartJunctionShapeNone) {
        return;
    }
    NSTimeInterval actualDelay = 0;
    if (animationStyle != WYRadarChartViewAnimationStrokePath) {
        actualDelay = delay;
    }
    for (NSInteger index = 0; index < self.junctions.count; index++) {
        actualDelay += ((index == 0) ? 0 : [(NSNumber *)self.subPathRatio[index - 1] floatValue]*duration);
        [(WYLineChartJunctionShape *)self.junctions[index] setAlpha:0];
        [(WYLineChartJunctionShape *)self.junctions[index] wy_addScaleSpringWithDelay:actualDelay reverse:NO];
    }
}

@end
