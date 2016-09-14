//
//  WYPieChartForegroundView.m
//  WYChart
//
//  Created by yingwang on 16/8/22.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYPieChartView.h"
#import "WYPieSector.h"
#import "WYChartCategory.h"
#import "WYPieChartForegroundView.h"

#define DEFAULT_LABEL_MAX_ALPHA 0.3
#define DEFAULT_LABEL_MAX_HEIGHT 22
#define DEFAULT_LABEL_MAX_WIDTH 70

#define DEFAULT_LABEL_MID_HEIGHT 15
#define DEFAULT_LABEL_MID_WIDTH 45

#define DEFAULT_LABEL_MIN_HEIGHT 10
#define DEFAULT_LABEL_MIN_WIDTH 40

#define DEFAULT_MAX_FONT_SIZE 10
#define DEFAULT_MIN_FONT_SIZE 10

@interface WYPieChartForegroundView ()

@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) CAShapeLayer *lineLayer;

@end

@implementation WYPieChartForegroundView

- (void)reloadData {
    
    NSInteger labelCount;
    NSString *textForLabel;
    UILabel *currentLabel;
    
    if ([_parentView.delegate respondsToSelector:@selector(numberOfLabelOnPieChartView:)]) {
        labelCount = [_parentView.delegate numberOfLabelOnPieChartView:_parentView];
    } else {
        return;
    }
    
    if (!_labels) _labels = [NSMutableArray array];
    
    for (NSInteger idx = 0; idx < labelCount; idx ++) {
        if (idx >= _labels.count) {
            currentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            currentLabel.textAlignment = NSTextAlignmentCenter;
            currentLabel.layer.cornerRadius = 2.0;
            currentLabel.clipsToBounds = true;
            currentLabel.font = [UIFont systemFontOfSize:8.0];
            
            const CGFloat* textColors = CGColorGetComponents(_labelsTextColor.CGColor);
            if (CGColorGetNumberOfComponents(_labelsTextColor.CGColor) == 2) {
                currentLabel.textColor = [UIColor colorWithRed:textColors[0] green:textColors[0] blue:textColors[0] alpha:textColors[1]];
            } else {
                currentLabel.textColor = [UIColor colorWithRed:textColors[0] green:textColors[1] blue:textColors[2] alpha:textColors[3]];
            }
            
            const CGFloat* colors = CGColorGetComponents(_labelsBackgroundColor.CGColor );
            if (CGColorGetNumberOfComponents(_labelsBackgroundColor.CGColor) == 2) {
                currentLabel.backgroundColor = [UIColor colorWithRed:colors[0] green:colors[0] blue:colors[0] alpha:colors[1]*DEFAULT_LABEL_MAX_ALPHA];
            } else {
                currentLabel.backgroundColor = [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:DEFAULT_LABEL_MAX_ALPHA];
            }
            
            [_labels addObject:currentLabel];
        } else {
            currentLabel = _labels[idx];
        }
        
        textForLabel = [_parentView.datasource pieChartView:_parentView textForLabelAtIndex:idx];
        currentLabel.text = textForLabel;
        [self addSubview:currentLabel];
    }
    
    for (NSInteger idx = labelCount; labelCount < _labels.count; ++idx) {
        [(UIView *)_labels[idx] removeFromSuperview];
    }
    [self updateWithRotateAngle:0];
}

- (void)updateWithRotateAngle:(CGFloat)angle {
    
    UIBezierPath *linePath;
    CGFloat labelHeight;
    CGFloat centerAngle;
    NSInteger labesCount;
    UILabel *currentLabel;
    NSInteger labelIdx;
    BOOL labelLeft;
    CGFloat fontSize;
    CGFloat heightAlpha, widthAlpha;
    CGRect labelFrame;
    CGFloat x, y, width, height;
    WYPieSector *sector;
    CGPoint startPoint, turningPoint, endPoint;
    
    linePath = [UIBezierPath bezierPath];
    if ([_parentView.delegate respondsToSelector:@selector(numberOfLabelOnPieChartView:)]) {
        labesCount = [_parentView.delegate numberOfLabelOnPieChartView:_parentView];
    } else {
        return;
    }
    
    for (NSInteger idx = 0; idx < labesCount; ++ idx) {
        currentLabel = _labels[idx];
        labelIdx = [_parentView.datasource pieChartView:_parentView valueIndexReferToLabelAtIndex:idx];
        sector = _sectors[idx];
        labelHeight = [sector heightOfArcOutsideWithRotateAngle:angle];
        centerAngle = sector.centerAngle+angle;
        startPoint = CGPointMake(self.wy_boundsCenter.x+cosf(centerAngle)*(sector.radius-10), self.wy_boundsCenter.y+sinf(centerAngle)*(sector.radius-10));
        turningPoint = CGPointMake(self.wy_boundsCenter.x+cosf(centerAngle)*(sector.outerRadius+10), self.wy_boundsCenter.y+sinf(centerAngle)*(sector.outerRadius+10));
        
        labelLeft = turningPoint.x<self.wy_boundsCenter.x;
        
        endPoint = CGPointMake(turningPoint.x+(labelLeft?-1:1)*10, turningPoint.y);
        
        [linePath moveToPoint:startPoint];
        [linePath addLineToPoint:turningPoint];
        [linePath addLineToPoint:endPoint];
        
        // reset label frame
        width = labelLeft ? endPoint.x : self.wy_boundsWidth-endPoint.x;
        width -= 10;
        width = width > DEFAULT_LABEL_MAX_WIDTH ? DEFAULT_LABEL_MAX_WIDTH : width;
        
        x = labelLeft ? endPoint.x - width : endPoint.x;
        height = labelHeight > DEFAULT_LABEL_MAX_HEIGHT ? DEFAULT_LABEL_MAX_HEIGHT : labelHeight;
        
        y = endPoint.y - height/2;
        labelFrame = CGRectMake(x, y, width, height);
        currentLabel.frame = labelFrame;
        
        width = width < DEFAULT_LABEL_MIN_WIDTH ? DEFAULT_LABEL_MIN_WIDTH : width;
        height = height < DEFAULT_LABEL_MIN_HEIGHT ? DEFAULT_LABEL_MIN_HEIGHT : height;
        widthAlpha = width < DEFAULT_LABEL_MID_WIDTH? 0.5+0.5*(width-DEFAULT_LABEL_MIN_WIDTH)/(DEFAULT_LABEL_MID_WIDTH-DEFAULT_LABEL_MIN_WIDTH):1.0;
        heightAlpha = height < DEFAULT_LABEL_MID_HEIGHT? 0.5+0.5*(height-DEFAULT_LABEL_MIN_HEIGHT)/(DEFAULT_LABEL_MID_HEIGHT-DEFAULT_LABEL_MIN_HEIGHT):1.0;
//        currentLabel.alpha = (widthAlpha<heightAlpha)?widthAlpha:heightAlpha;
        
        fontSize = ((widthAlpha<heightAlpha)?widthAlpha:heightAlpha) * DEFAULT_MAX_FONT_SIZE;
        currentLabel.font = [UIFont systemFontOfSize:fontSize];
    }
    
    if (!_lineLayer) {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.opacity = 0.6;
        _lineLayer.strokeColor = [UIColor grayColor].CGColor;
        _lineLayer.fillColor = [UIColor clearColor].CGColor;
        _lineLayer.lineWidth = 1.0;
        [self.layer addSublayer:_lineLayer];
    }
    
    _lineLayer.path = linePath.CGPath;
}

@end
