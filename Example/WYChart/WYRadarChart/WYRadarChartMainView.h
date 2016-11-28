//
//  WYRadarChartMainView.h
//  WYChart
//
//  Created by Allen on 25/11/2016.
//  Copyright © 2016年 Allen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYRadarChartMainView : UIView

@property (nonatomic, assign) NSInteger dimensionCount;
@property (nonatomic, assign) NSInteger gradient;

- (instancetype)initWithFrame:(CGRect)frame;

@end
