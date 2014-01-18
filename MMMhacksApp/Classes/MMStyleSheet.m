//
//  MMStyleSheet.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMStyleSheet.h"

@implementation MMStyleSheet

#pragma mark - + MMStyleSheet

+ (instancetype)sharedInstance
{
    static id styleSheet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        styleSheet = [[MMStyleSheet alloc] init];
    });
    return styleSheet;
}

#pragma mark - MMStyleSheet

- (UIColor *)mainGrayColor
{
    return [UIColor colorWithWhite:176.f/255.f alpha:1.0];
}

@end
