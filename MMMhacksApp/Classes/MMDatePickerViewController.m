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
#import "MMConnectionLine.h"

#define DAYS 5
#define HOURS 6

@interface MMDatePickerViewController ()

@property (nonatomic, strong) NSArray *_nodeDotViews;
@property (nonatomic, strong) NSArray *_dateDotViews;
@property (nonatomic, strong) UIDynamicAnimator *_nodesAnimator;

@end

@implementation MMDatePickerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __nodeDotViews = [[NSArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //
    NSMutableArray *dotViews = [[NSMutableArray alloc] initWithCapacity:DAYS * HOURS];
    for (NSInteger i=0; i< DAYS * HOURS; i++) {
        MMNodeDot *dot = [[MMNodeDot alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [dotViews addObject:dot];
    }
    __nodeDotViews = [dotViews mutableCopy];
    
    // Set up date dots
    NSMutableArray *dateDots = [[NSMutableArray alloc] initWithCapacity:DAYS];
    for (NSInteger i=0; i<DAYS; i++) {
        NSInteger dotDay = i % DAYS;
        
        MMDateDot *dateDot = [[MMDateDot alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        dateDot.center = CGPointMake(240 + 140 * dotDay, 100);
        [dateDots addObject:dateDot];
        [self.view addSubview:dateDot];
    }
    __dateDotViews = [dateDots mutableCopy];
    
    // Set up dots
    for (NSInteger i=0; i<[__nodeDotViews count]; i++) {
        // Add dots to a view
        MMNodeDot *dot = __nodeDotViews[i];
        dot.center = [dateDots[i % DAYS] center];
        [self.view addSubview:dot];
        
        // Add tap gesture recognizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(_handleTapGestureOnDot:)];
        dot.tag = i;
        [dot addGestureRecognizer:tapGesture];
        
        
        // Pan gesture
        UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(_handlePanGesture:)];
        [dot addGestureRecognizer:swipeGesture];
        
    }
    
    // Set up animator
    self._nodesAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(_animateDotsToCorrectPositions) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(_connectDots) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(_addHoursLables) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(_addHorizontalLines) withObject:nil afterDelay:2.0];
    //    [self _animateDotsToCorrectPositions];
}

#pragma mark - MMDatePickerViewController ()

- (void)_connectDots
{
    // Connect Date dots with first node dots
    for (NSInteger i=0; i<DAYS; i++) {
        MMConnectionLine *line = [[MMConnectionLine alloc] init];
        [self.view insertSubview:line atIndex:0];
        [line connectBetweenView:self._dateDotViews[i]
                      secondView:self._nodeDotViews[i]];
    }

    NSInteger count = 0;
    for (NSInteger i=0; i<DAYS; i++) {
        for (NSInteger j=0; j<HOURS-1; j++) {
            NSInteger nodeDotIndex = i + DAYS*j;
            MMNodeDot *nodeDot = self._nodeDotViews[nodeDotIndex];
            MMNodeDot *nextNodeDot = self._nodeDotViews[nodeDotIndex + DAYS];
            MMConnectionLine *line = [[MMConnectionLine alloc] init];
            [self.view insertSubview:line atIndex:0];
            [line connectBetweenView:nodeDot secondView:nextNodeDot];
            count++;
        }
    }
}

- (void)_animateDotsToCorrectPositions
{
    for (NSInteger i=0; i<[__nodeDotViews count]; i++) {
        // Add dots to a view
        MMNodeDot *dot = __nodeDotViews[i];
        
        NSInteger dotDay = i % DAYS;
        NSInteger dotHour = i / HOURS;
        
        CGPoint dotCenter = CGPointMake(240 + 140 * dotDay,
                                        200 + 100 * dotHour);
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:dot
                                                        snapToPoint:dotCenter];
        snap.damping = 0.8f;
        [self._nodesAnimator addBehavior:snap];
    }
}

- (void)_addHoursLables
{
    for (NSInteger i=0; i<HOURS; i++) {
        UILabel *hourLabel = [[UILabel alloc] init];
        hourLabel.backgroundColor = [UIColor clearColor];
        hourLabel.textColor = [UIColor darkGrayColor];
        hourLabel.text = @"9:00 AM";
        [hourLabel sizeToFit];
        [self.view addSubview:hourLabel];
        
        MMNodeDot *firstHourNode = self._nodeDotViews[DAYS*i];
        
        hourLabel.center = CGPointMake(firstHourNode.center.x - 150,
                                       firstHourNode.center.y);
    }
}

- (void)_addHorizontalLines
{
    for (NSInteger i=0; i<HOURS; i++) {
        MMNodeDot *firstHourNode = self._nodeDotViews[DAYS*i];
        MMNodeDot *lastHourNode = self._nodeDotViews[DAYS*i + DAYS-1];
        
        MMConnectionLine *line = [[MMConnectionLine alloc] init];
        line.type = MMLineHorizontal;
        [self.view insertSubview:line atIndex:0];
        [line connectBetweenPoint:CGPointMake(firstHourNode.center.x - 100, firstHourNode.center.y)
                      secondPoint:CGPointMake(lastHourNode.center.x, lastHourNode.center.y)];
    }
}

#pragma mark - Gesture Handlers

- (void)_handleTapGestureOnDot:(UITapGestureRecognizer *)gesture
{
    NSInteger tappedDotIndex = gesture.view.tag;
    MMNodeDot *tappedDot = self._nodeDotViews[tappedDotIndex];
    
    [UIView animateWithDuration:0.3 animations:^{
        tappedDot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            tappedDot.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view.superview];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            MMNodeDot *dot = ((MMNodeDot *)gesture.view);
            dot.selected = YES;
        }
        case UIGestureRecognizerStateChanged: {
            for (MMNodeDot *dot in self._nodeDotViews) {
                if (CGRectContainsPoint(dot.frame, location)) {
                    dot.selected = YES;
                    CGPoint transl = [gesture translationInView:gesture.view.superview];
                    if (dot.tag != 99) {
                        UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[dot] mode:UIPushBehaviorModeInstantaneous];
                        push.pushDirection = CGVectorMake(-transl.x, -transl.y);
                        push.magnitude = 0.4f;
                        [self._nodesAnimator addBehavior:push];
                    }
                    dot.tag = 99;
                }
            }
        }
            break;

        default:
            break;
    }
}

@end
