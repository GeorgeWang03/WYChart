//
//  WYRadarChartView.m
//  WYChart
//
//  Created by Allen on 25/11/2016.
//  Copyright © 2016年 Allen. All rights reserved.
//

#import "WYRadarChartView.h"
#import "WYRadarChartMainView.h"

@interface WYRadarChartView()

@property (nonatomic, strong) WYRadarChartMainView *radarMainView;

@end

@implementation WYRadarChartView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.radarMainView = [[WYRadarChartMainView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self addSubview:self.radarMainView];
}

@end
