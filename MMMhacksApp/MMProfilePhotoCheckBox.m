//
//  MMProfilePhotoCheckBox.m
//  MMMhacksApp
//
//  Created by Maciej Lobodzinski on 18/01/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMProfilePhotoCheckBox.h"
#import "MMStyleSheet.h"

@implementation MMProfilePhotoCheckBox

- (id)initWithType:(CheckBoxType)checkBoxType andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.checkBoxType = checkBoxType;
    }
    return self;
}

- (void)layoutSubviews
{
    UIView *checkBox = [[UIView alloc] initWithFrame:self.frame];
    checkBox.layer.cornerRadius = checkBox.frame.size.width/2;
    
    UILabel *signLabel = [[UILabel alloc] initWithFrame:self.frame];
    signLabel.textAlignment = NSTextAlignmentCenter;
    
    if (self.checkBoxType == CheckBoxTypeGreen) {
        signLabel.text = @"V";
        checkBox.backgroundColor = [[MMStyleSheet sharedInstance] greenColor];
    }
    else {
        signLabel.text = @"X";
        checkBox.backgroundColor = [[MMStyleSheet sharedInstance] redColor];
    }
    
    [checkBox addSubview:signLabel];
    [self addSubview:checkBox];
}

@end
