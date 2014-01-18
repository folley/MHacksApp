//
//  MMDateDot.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMDateDot.h"
#import "MMStyleSheet.h"

const float kMargin = 10;

@interface MMDateDot ()
@property (nonatomic, readwrite) UILabel *dateLabel;
@property (nonatomic, readwrite) UILabel *dayLabel;
@end

@implementation MMDateDot

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UIView *borderView = [[UIView alloc] initWithFrame:self.frame];
        borderView.layer.cornerRadius = self.frame.size.width/2;
        borderView.layer.borderColor = [[[MMStyleSheet sharedInstance] mainDarkGrayColor] CGColor];
        borderView.layer.borderWidth = 1;
        borderView.backgroundColor = [[MMStyleSheet sharedInstance] mainLightGrayColor];
        
        [self addSubview:borderView];

        
        UIView *blueCircleView = [[UIView alloc] initWithFrame:CGRectMake(kMargin, kMargin,
                                                                          self.frame.size.width-2*kMargin,
                                                                          self.frame.size.height-2*kMargin)];
        blueCircleView.layer.cornerRadius = blueCircleView.frame.size.width/2;
        blueCircleView.backgroundColor = [[MMStyleSheet sharedInstance] blueColor];
        
        [self addSubview:blueCircleView];
        
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
                                            40);
        [self addSubview:_dateLabel];
        
        // Day label
        _dayLabel = [[UILabel alloc] init];
        _dayLabel.backgroundColor = [UIColor clearColor];
        _dayLabel.textColor = [UIColor whiteColor];
        _dayLabel.text = @"Mon";
        _dayLabel.font = [UIFont fontWithName:@"Raleway-Medium" size:15];
        [_dayLabel sizeToFit];
        self.dayLabel.center = CGPointMake(self.bounds.size.width/2.f,
                                           self.bounds.size.height - _dayLabel.bounds.size.height-15);
        [self addSubview:_dayLabel];
    }
    return self;
}

@end
