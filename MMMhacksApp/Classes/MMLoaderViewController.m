//
//  MMLoaderViewController.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/19/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMLoaderViewController.h"
#import <Parse/Parse.h>
#import "MMPerson.h"
#import "MMDatePickerViewController.h"

@implementation MMLoaderViewController

#pragma mark - MMLoaderViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor lightGrayColor];
        [self _loadPeopleData];
    }
    return self;
}

#pragma mark - 

- (void)_loadPeopleData
{
    PFQuery *query = [PFQuery queryWithClassName:@"MMPerson"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"downloaded");
        if (!error) {
            NSMutableArray *allPeople = [[NSMutableArray alloc] initWithCapacity:5];
            for (PFObject *parseObject in objects) {
                MMPerson *person = [[MMPerson alloc] initWithParseObject:parseObject];
                [allPeople addObject:person];
            }

            MMDatePickerViewController *pickerVC = [[MMDatePickerViewController alloc] initWithMainPerson:allPeople[0]
                                                                                                   people:allPeople];
            [self presentViewController:pickerVC
                               animated:YES
                             completion:nil];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
