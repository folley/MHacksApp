//
//  MMPerson.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMPerson.h"

@implementation MMPerson

- (instancetype)init
{
    if (self = [super init]) {
        self.avatarImage = [UIImage imageNamed:@"michalAvatar"];
    }
    return self;
}

@end
