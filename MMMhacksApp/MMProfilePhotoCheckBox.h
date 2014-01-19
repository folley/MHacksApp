//
//  MMProfilePhotoCheckBox.h
//  MMMhacksApp
//
//  Created by Maciej Lobodzinski on 18/01/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CheckBoxType) {
    CheckBoxTypeGreen,
    CheckBoxTypeRed,
};

@interface MMProfilePhotoCheckBox : UIView

@property (nonatomic) CheckBoxType checkBoxType;

- (id)initWithType:(CheckBoxType)checkBoxType andFrame:(CGRect)frame;

@end
