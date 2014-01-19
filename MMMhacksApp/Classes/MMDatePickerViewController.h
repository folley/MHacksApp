//
//  MMDatePickerViewController.h
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPerson.h"

@interface MMDatePickerViewController : UIViewController

- (instancetype)initWithMainPerson:(MMPerson *)myPerson people:(NSArray *)people;

@end
