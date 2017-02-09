//
//  WYRadarChartDimensionView.m
//  WYChart
//
//  Created by Allen on 09/12/2016.
//  Copyright © 2016 Allen. All rights reserved.
//

#import "WYRadarChartDimensionView.h"
#import "WYRadarChartModel.h"

@interface WYRadarChartDimensionView ()

@property (nonatomic, strong) WYRadarChartDimension *dimension;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation WYRadarChartDimensionView

- (instancetype)initWithDimension:(WYRadarChartDimension *)dimension {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _dimension = dimension;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    if (self.dimension.title) {
        self.titleLabel = [UILabel new];
        self.titleLabel.text = self.dimension.title;
        self.titleLabel.textColor = self.dimension.titleColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        if (self.dimension.titleFont) {
            self.titleLabel.font = self.dimension.titleFont;
        }
        else {
            self.titleLabel.font = [UIFont systemFontOfSize:12];
        }
        [self.titleLabel sizeToFit];
        [self addSubview:self.titleLabel];
    }
    if (self.dimension.icon) {
        self.imageView = [[UIImageView alloc] initWithImage:self.dimension.icon];
        [self.imageView sizeToFit];
        [self addSubview:self.imageView];
    }
    if (self.dimension.viewSize.width >= 0) {
        self.bounds = CGRectMake(0, 0, self.dimension.viewSize.width, self.dimension.viewSize.height);
        self.imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.imageView.bounds)*0.5 + 1);
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame), self.dimension.viewSize.width, self.dimension.viewSize.height - CGRectGetHeight(self.imageView.bounds));
        self.titleLabel.center = CGPointMake(CGRectGetMidX(self.bounds), self.titleLabel.center.y);
    }
    else {
        self.bounds = CGRectMake(0, 0, CGRectGetWidth(self.titleLabel.bounds) > CGRectGetWidth(self.imageView.bounds) ? CGRectGetWidth(self.titleLabel.bounds) + 5: CGRectGetWidth(self.imageView.bounds) + 5, CGRectGetHeight(self.titleLabel.bounds) + CGRectGetHeight(self.imageView.bounds) + 5);
        self.titleLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.imageView.bounds) + 4 + CGRectGetHeight(self.titleLabel.bounds)*0.5);
        self.imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.imageView.bounds)*0.5 + 1);
    }
}


@end
