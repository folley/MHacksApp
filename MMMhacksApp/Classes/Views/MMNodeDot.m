//
//  MMDateDot.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMNodeDot.h"
#import "MMStyleSheet.h"

@implementation MMNodeDot

#pragma mark - Setters / Getters

- (void)setSelected:(BOOL)selected
{
    BOOL togglingToActive = selected && !_selected;
    
    UIColor *toFadeColor = togglingToActive ? [UIColor blackColor] : [[MMStyleSheet sharedInstance] mainGrayColor];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = toFadeColor;
            self.transform = CGAffineTransformIdentity;
        }];
    }];
    
    _selected = selected;
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[MMStyleSheet sharedInstance] mainGrayColor];
        self.layer.cornerRadius = frame.size.width/2.f;
    }
    return self;
}

@end
