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
@property (nonatomic, readwrite) UILabel *dayLabel;
@end

@implementation MMDateDot

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = frame.size.width/2.f;
        self.backgroundColor = [UIColor blackColor];
        
        // Date label
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.text = @"15";
        _dateLabel.font = [UIFont fontWithName:@"Raleway-Light" size:36];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        [_dateLabel sizeToFit];
        _dateLabel.frame = CGRectMake(0, 0, _dateLabel.frame.size.width + 20, _dateLabel.frame.size.height);
        self.dateLabel.center = CGPointMake(self.frame.size.width/2.f,
                                            33);
        [self addSubview:_dateLabel];
        
        // Day label
        _dayLabel = [[UILabel alloc] init];
        _dayLabel.backgroundColor = [UIColor clearColor];
        _dayLabel.textColor = [UIColor whiteColor];
        _dayLabel.text = @"Mon";
        _dayLabel.font = [UIFont fontWithName:@"Raleway-Medium" size:15];
        [_dayLabel sizeToFit];
        self.dayLabel.center = CGPointMake(self.bounds.size.width/2.f,
                                           self.bounds.size.height - _dayLabel.bounds.size.height-10);
        [self addSubview:_dayLabel];
    }
    return self;
}

@end
