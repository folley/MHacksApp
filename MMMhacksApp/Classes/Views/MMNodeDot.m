//
//  MMDateDot.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMNodeDot.h"
#import "MMStyleSheet.h"

@interface MMNodeDot ()
//@property (nonatomic, strong) UIView *_dotView;
@end

@implementation MMNodeDot

#pragma mark - Setters / Getters

- (void)setSelected:(BOOL)selected
{
    BOOL togglingToActive = selected && !_selected;

    UIColor *toFadeColor = togglingToActive ? [UIColor blackColor] : [[MMStyleSheet sharedInstance] mainGrayColor];
    
    UIView *animatedDot = [[UIView alloc] initWithFrame:self._dotView.frame];
    animatedDot.layer.cornerRadius = self._dotView.layer.cornerRadius;
    animatedDot.backgroundColor = self._dotView.backgroundColor;
    [self addSubview:animatedDot];

    [UIView animateWithDuration:0.6 animations:^{
        animatedDot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.5, 2.5);
        animatedDot.alpha = 0.f;
        
        self._dotView.backgroundColor = toFadeColor;
    } completion:^(BOOL finished) {
        [animatedDot removeFromSuperview];
    }];
    
    _selected = selected;
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Dot view
        __dotView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 13, 13)];
        __dotView.backgroundColor = [[MMStyleSheet sharedInstance] mainGrayColor];
        __dotView.layer.cornerRadius = __dotView.frame.size.width/2.f;
        __dotView.userInteractionEnabled = NO;
        __dotView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:__dotView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
