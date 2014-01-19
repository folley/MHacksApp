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
    return [UIColor colorWithWhite:125./255. alpha:1.0];
}

- (UIColor *)mainLightGrayColor
{
    return [UIColor colorWithWhite:212./255. alpha:1.0];
}

- (UIColor *)mainDarkGrayColor
{
    return [UIColor colorWithWhite:22./255. alpha:1.0];
}

- (UIColor *)navBarBgColor
{
    return [UIColor colorWithWhite:179./255. alpha:1.0];
}

- (UIColor *)blueColor
{
    return [UIColor colorWithRed:50/255. green:152/255. blue:218/255. alpha:1.];
}

- (UIColor *)greenColor
{
    return [UIColor colorWithRed:45/255. green:204/255. blue:112/255. alpha:1.];
}

- (UIColor *)redColor
{
    return [UIColor colorWithRed:231/255. green:75/255. blue:60/255. alpha:1.];
}

@end
