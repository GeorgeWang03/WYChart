//
//  WYLineChartLabelsView.m
//  Pods
//
//  Created by yingwang on 2016/11/20.
//
//

#import "WYLineChartView.h"
#import "WYLineChartPoint.h"
#import "WYLineChartLabelsView.h"

@implementation WYLineChartLabelsView

- (void)drawRect:(CGRect)rect {
    
    //remove subviews
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.backgroundColor = [UIColor clearColor];
    
    BOOL isRespondToLabelTextMethod = NO;
    isRespondToLabelTextMethod = [self.parentView.datasource respondsToSelector:@selector(lineChartView:contextTextForPointAtIndexPath:)];
    
    if (!isRespondToLabelTextMethod) return;
    
    CGFloat centerY = CGRectGetMidY(self.bounds);
    
    NSString *text;
    UILabel *label;
    CGFloat labelY;
    CGFloat labelHeight = 14;
    CGFloat labelWidth = fmin([self.parentView.delegate gapBetweenPointsHorizontalInLineChartView:self.parentView], 50);
    for (NSUInteger fidx = 0; fidx < self.parentView.points.count; fidx ++) {
        NSArray *pointsArray = self.parentView.points[fidx];
        for (NSUInteger sidx = 0; sidx < pointsArray.count; sidx ++) {
            WYLineChartPoint *point = pointsArray[sidx];
            text = [self.parentView.datasource lineChartView:self.parentView contextTextForPointAtIndexPath:[NSIndexPath indexPathForRow:sidx inSection:fidx]];
            if (!text) continue;
            
            labelY = point.y  + (point.y > centerY ? (- labelHeight/2 - 5) : (labelHeight/2 + 5));
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
            
            if (!self.parentView.scrollable && !sidx) {
                label.frame = CGRectMake(point.x, labelY-labelHeight/2, labelWidth, labelHeight);
            } else if (!self.parentView.scrollable && point.x+labelWidth/2 > CGRectGetMaxX(self.bounds)) {
                label.frame = CGRectMake(point.x-labelWidth, labelY-labelHeight/2, labelWidth, labelHeight);
            } else {
                label.center = CGPointMake(point.x, labelY);
            }
            
            label.textAlignment = NSTextAlignmentCenter;
            label.text = text;
            label.font = [UIFont systemFontOfSize:10.f];
            label.textColor = self.parentView.pointsLabelsColor;
            label.backgroundColor = [self.parentView.pointsLabelsBackgroundColor colorWithAlphaComponent:0.5];
            label.layer.cornerRadius = 2.f;
            label.layer.masksToBounds = YES;
            
            [self addSubview:label];
        }
    }
}


@end
