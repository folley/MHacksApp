//
//  MMConnectionLine.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMConnectionLine.h"

@implementation MMConnectionLine

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

#pragma mark - MMConnectionLine

- (void)connectBetweenView:(UIView *)Aview secondView:(UIView *)BView
{
    self.frame = CGRectMake(Aview.center.x,
                            Aview.center.y,
                            4,
                            BView.center.y - Aview.center.y);
}

@end
