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
    
    UIView *animatedDot = [[UIView alloc] initWithFrame:self.bounds];
    animatedDot.layer.cornerRadius = self.layer.cornerRadius;
    animatedDot.backgroundColor = self.backgroundColor;
    [self addSubview:animatedDot];
    
    [UIView animateWithDuration:0.6 animations:^{
        animatedDot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.5, 2.5);
        animatedDot.alpha = 0.f;
        
        self.backgroundColor = toFadeColor;
    } completion:^(BOOL finished) {
        [animatedDot removeFromSuperview];
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
