//
//  MMDateDot.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMDateDot.h"

@interface MMDateDot ()
@property (nonatomic, readwrite) UILabel *dateLabel;
@end

@implementation MMDateDot

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = frame.size.width/2.f;
        self.backgroundColor = [UIColor blackColor];
        
        // Date label
        self.dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.text = @"15 Mon";
        [self addSubview:self.dateLabel];
    }
    return self;
}

@end
