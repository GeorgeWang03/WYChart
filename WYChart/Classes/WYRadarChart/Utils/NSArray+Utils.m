//
//  NSArray+Utils.m
//  WYChart
//
//  Created by Allen on 29/11/2016.
//  Copyright © 2016 FreedomKing. All rights reserved.
//

#import "NSArray+Utils.h"

@implementation NSArray(Utils)

+ (instancetype)arrayByRepeatObject:(id)object time:(NSUInteger)time {
    id array[time];
    for (NSUInteger index = 0; index < time; index++) {
        array[index] = object;
    }
    return [NSArray arrayWithObjects:array count:time];
}

@end
