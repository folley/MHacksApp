//
//  MMStyleSheet.h
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMStyleSheet : NSObject

+ (instancetype)sharedInstance;

- (UIColor *)mainGrayColor;
- (UIColor *)mainLightGrayColor;
- (UIColor *)mainDarkGrayColor;

- (UIColor *)blueColor;
- (UIColor *)greenColor;
- (UIColor *)redColor;

- (UIColor *)navBarBgColor;



@end
