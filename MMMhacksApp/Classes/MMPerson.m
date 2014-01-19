//
//  MMPerson.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMPerson.h"

@interface MMPerson ()
@property (nonatomic, strong, readwrite) PFObject *parseObject;
@end

@implementation MMPerson

- (instancetype)initWithParseObject:(PFObject *)parseObject
{
    if (self = [super init]) {
        self.parseObject = parseObject;
        
        NSData *fileData = [parseObject[@"avatarImage"] getData];
        self.avatarImage = [UIImage imageWithData:fileData];
        
        self.rankedHours = parseObject[@"rankedHours"];
    }
    return self;
}

@end
