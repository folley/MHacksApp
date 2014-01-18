//
//  MMDatePickerViewController.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMDatePickerViewController.h"
#import "MMNodeDot.h"
#import "MMDateDot.h"

@interface MMDatePickerViewController ()

@property (nonatomic, strong) NSArray *_dateDotViews;

@end

@implementation MMDatePickerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __dateDotViews = [[NSArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSInteger const DAYS = 5;
    NSInteger const HOURS = 6;
    //
    NSMutableArray *dotViews = [[NSMutableArray alloc] initWithCapacity:5 * 6];
    for (NSInteger i=0; i< DAYS * HOURS; i++) {
        MMNodeDot *dot = [[MMNodeDot alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [dotViews addObject:dot];
    }
    __dateDotViews = [dotViews mutableCopy];
    
    // Set up date dots
    for (NSInteger i=0; i<DAYS; i++) {
        NSInteger dotDay = i % DAYS;
        
        MMDateDot *dateDot = [[MMDateDot alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        dateDot.center = CGPointMake(240 + 140 * dotDay, 100);
        [self.view addSubview:dateDot];
    }
    
    // Set up dots
    for (NSInteger i=0; i<[__dateDotViews count]; i++) {
        // Add dots to a view
        MMNodeDot *dot = __dateDotViews[i];
        
        NSInteger dotDay = i % DAYS;
        NSInteger dotHour = i / HOURS;
        
        dot.center = CGPointMake(240 + 140 * dotDay,
                                 200 + 100 * dotHour);
        [self.view addSubview:dot];
        
        
        // Add tap gesture recognizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(_handleTapGestureOnDot:)];
        dot.tag = i;
//        [dot addGestureRecognizer:tapGesture];
        
        
        
        // Pan gesture
        UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(_handlePanGesture:)];
        [dot addGestureRecognizer:swipeGesture];
        
    }
}

#pragma mark - MMDatePickerViewController ()

- (void)_handleTapGestureOnDot:(UITapGestureRecognizer *)gesture
{
    NSInteger tappedDotIndex = gesture.view.tag;
    MMNodeDot *tappedDot = self._dateDotViews[tappedDotIndex];
    
    [UIView animateWithDuration:0.3 animations:^{
        tappedDot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            tappedDot.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)_handlePanGesture:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view.superview];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            MMNodeDot *dot = ((MMNodeDot *)gesture.view);
            dot.selected = YES;
        }
        case UIGestureRecognizerStateChanged: {
            for (MMNodeDot *dot in self._dateDotViews) {
                if (CGRectContainsPoint(dot.frame, location)) {
                    dot.selected = YES;
                }
            }
        }
            break;

        default:
            break;
    }
}

@end
