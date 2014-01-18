//
//  MMPerson.h
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMPerson : NSObject

@property (nonatomic, strong) UIImage *avatarImage;
/**
 Format:
 @{<day> : @[0, 1, 2, ..],
   <day2> : @[..........]}
 */
@property (nonatomic, strong) NSDictionary *rankedHours;

@end
