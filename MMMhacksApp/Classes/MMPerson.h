//
//  MMPerson.h
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface MMPerson : NSObject

- (instancetype)initWithParseObject:(PFObject *)parseObject;

@property (nonatomic, strong, readonly) PFObject *parseObject;

@property (nonatomic, strong) UIImage *avatarImage;
/**
 Format:
 @{<day> : @[0, 1, 2, ..],
   <day2> : @[..........]}
 */
@property (nonatomic, strong) NSArray *rankedHours;

@end
