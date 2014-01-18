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
#import "MMPerson.h"

#define DAYS 5
#define HOURS 5

@interface MMDatePickerViewController ()

@property (nonatomic, strong) NSMutableArray *_nodeDotViews;
@property (nonatomic, strong) NSArray *_dateDotViews;
@property (nonatomic, strong) UIDynamicAnimator *_nodesAnimator;
@property (nonatomic, strong) NSMutableArray *_nodesConnectionLines;
@property (nonatomic, strong) NSArray *_people;

@end

@implementation MMDatePickerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __nodeDotViews = [[NSMutableArray alloc] init];
    __nodesConnectionLines = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // People
    NSMutableArray *allPeople = [[NSMutableArray alloc] initWithCapacity:5];
    for (NSInteger i=0; i<5; i++) {
        MMPerson *person = [[MMPerson alloc] init];
        [allPeople addObject:person];
    }
    self._people = [allPeople mutableCopy];
    //
    for (NSInteger i=0; i< DAYS * HOURS; i++) {
        MMNodeDot *dot = [[MMNodeDot alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
        dot.tag = i;
        
        [__nodeDotViews addObject:dot];
    }
    
    // Set up date dots
    NSMutableArray *dateDots = [[NSMutableArray alloc] initWithCapacity:DAYS];
    NSMutableArray *weekdaysNames = @[@"monday", @"tuesday", @"wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
    
    for (NSInteger i=0; i<DAYS; i++) {
        NSInteger dotDay = i % DAYS;
        
        MMDateDot *dateDot = [[MMDateDot alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        dateDot.dateLabel.text = [NSString stringWithFormat:@"%i", 15 + i];
        dateDot.dayLabel.text = [((NSString *)[weekdaysNames objectAtIndex:i]).uppercaseString substringToIndex:3];
        dateDot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100, 1./100);
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
        dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100, 1./100);
        [self.view insertSubview:dot atIndex:0];
        
        // Add tap gesture recognizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(_handleTapGestureOnDot:)];
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
    
    [self performSelector:@selector(_showDaysDots) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(_animateDotsToCorrectPositions) withObject:nil afterDelay:1.6];
    [self performSelector:@selector(_connectDots) withObject:nil afterDelay:2.2];
    [self performSelector:@selector(_addHoursLables) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(_addHorizontalLines) withObject:nil afterDelay:2.0];
    [self _addPeopleAvatars];
}

#pragma mark - MMDatePickerViewController ()

- (void)_addPeopleAvatars
{
    for (NSInteger i=0; i<[self._people count]; i++) {
        MMPerson *person = self._people[i];
        UIImageView *avatarView = [[UIImageView alloc] initWithImage:person.avatarImage];
        avatarView.frame = CGRectMake(0, 0, 60, 60);
        avatarView.layer.cornerRadius = avatarView.frame.size.width/2.f;
        avatarView.clipsToBounds = YES;
        avatarView.center = CGPointMake(260 + 110*i,
                                        self.view.bounds.size.height - 100);
        [self.view addSubview:avatarView];
    }
}

- (void)_showDaysDots
{
    for (UIView *dateDot in self._dateDotViews) {
        [UIView animateWithDuration:0.3 animations:^{
            dateDot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                dateDot.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

- (void)_connectDots
{
    // Connect Date dots with first node dots
    for (NSInteger i=0; i<DAYS; i++) {
        MMConnectionLine *line = [[MMConnectionLine alloc] init];
        line.alpha = 0.f;
        [self.view insertSubview:line atIndex:0];
        [line connectBetweenView:self._dateDotViews[i]
                      secondView:self._nodeDotViews[i]];
        
        [UIView animateWithDuration:0.3 animations:^{
            line.alpha = 1.f;
        }];
        
    }

    for (NSInteger j=0; j<HOURS-1; j++) {
        for (NSInteger i=0; i<DAYS; i++) {
            NSInteger nodeDotIndex = i + DAYS*j;
            MMNodeDot *nodeDot = self._nodeDotViews[nodeDotIndex];
            MMNodeDot *nextNodeDot = self._nodeDotViews[nodeDotIndex + DAYS];
            MMConnectionLine *line = [[MMConnectionLine alloc] init];
            line.alpha = 0.f;
            [self._nodesConnectionLines addObject:line];
            [self.view insertSubview:line atIndex:0];
            [line connectBetweenView:nodeDot secondView:nextNodeDot];
            
            [UIView animateWithDuration:0.3 animations:^{
                line.alpha = 1.f;
            }];
        }
    }
}

- (void)_animateDotsToCorrectPositions
{
    for (NSInteger i=0; i<[__nodeDotViews count]; i++) {
        // Add dots to a view
        MMNodeDot *dot = __nodeDotViews[i];

        NSInteger dotDay = i % DAYS;
        NSInteger dotHour = i / DAYS;
        
        CGPoint dotCenter = CGPointMake(240 + 140 * dotDay,
                                        200 + 100 * dotHour);
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:dot
                                                        snapToPoint:dotCenter];
        snap.damping = 0.8f;
        [self._nodesAnimator addBehavior:snap];
        
        //
        [UIView animateWithDuration:0.3 animations:^{
            dot.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)_addHoursLables
{
    NSInteger randomHour = 9;
    for (NSInteger i=0; i<HOURS; i++) {
        UILabel *hourLabel = [[UILabel alloc] init];
        hourLabel.font = [UIFont fontWithName:@"Raleway-Light" size:17.f];
        hourLabel.backgroundColor = [UIColor clearColor];
        hourLabel.textColor = [UIColor darkGrayColor];
        hourLabel.text = [NSString stringWithFormat:@"%i:00 %@", randomHour, randomHour < 12 ? @"AM" : @"PM"];
        [hourLabel sizeToFit];
        [self.view addSubview:hourLabel];
        
        MMNodeDot *firstHourNode = self._nodeDotViews[DAYS*i];
        
        hourLabel.center = CGPointMake(firstHourNode.center.x - 150,
                                       firstHourNode.center.y);
        
        randomHour++;
    }
}

- (void)_addHorizontalLines
{
    for (NSInteger i=0; i<HOURS; i++) {
        MMNodeDot *firstHourNode = self._nodeDotViews[DAYS*i];
        MMNodeDot *lastHourNode = self._nodeDotViews[DAYS*i + DAYS-1];
        
        MMConnectionLine *line = [[MMConnectionLine alloc] init];
        line.type = MMLineHorizontal;
        line.alpha = 0.1f;
        [self.view insertSubview:line atIndex:0];
        [line connectBetweenPoint:CGPointMake(firstHourNode.center.x - 100, firstHourNode.center.y)
                      secondPoint:CGPointMake(lastHourNode.center.x, lastHourNode.center.y)];
    }
}

- (MMNodeDot *)_nextHour:(MMNodeDot *)node
{
    NSInteger currentIndex = node.tag;
    NSInteger nextIndex = currentIndex + DAYS;
    
    if (nextIndex >= [self._nodeDotViews count]) {
        return nil;
    }
    else {
        return self._nodeDotViews[nextIndex];
    }
}

- (MMNodeDot *)_previousHours:(MMNodeDot *)node
{
    NSInteger currentIndex = node.tag;
    NSInteger previousIndex = currentIndex - DAYS;
    
    if (previousIndex < 0) {
        return nil;
    }
    else {
        return self._nodeDotViews[previousIndex];
    }
}

- (MMConnectionLine *)_connectionBetweenNode:(MMNodeDot *)ANode secondNode:(MMNodeDot *)BNode
{
    if (!(BNode && ANode)) {
        return nil;
    }
    return self._nodesConnectionLines[ANode.tag];
}

- (void)_updateConnectionLines
{
    for (NSInteger i=0; i<[self._nodeDotViews count]; i++) {
        MMNodeDot *dot = self._nodeDotViews[i];
        // Select connections if needed
        MMNodeDot *prev = [self _previousHours:dot];
        MMNodeDot *next = [self _nextHour:dot];
        
        MMConnectionLine *lineDotPrev = [self _connectionBetweenNode:prev secondNode:dot];
        lineDotPrev.highlighted = dot.isSelected && prev.isSelected;
        
        MMConnectionLine *lineDotNext = [self _connectionBetweenNode:dot secondNode:next];
        lineDotNext.highlighted = dot.isSelected && next.isSelected;
    }
}

#pragma mark - Gesture Handlers

- (void)_handleTapGestureOnDot:(UITapGestureRecognizer *)gesture
{
    NSInteger tappedDotIndex = gesture.view.tag;
    MMNodeDot *tappedDot = self._nodeDotViews[tappedDotIndex];
    
    tappedDot.selected = !tappedDot.isSelected;
    [self _updateConnectionLines];
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view.superview];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            MMNodeDot *dot = ((MMNodeDot *)gesture.view);
            dot.selected = !dot.isSelected;
            // Disable for futher interaction
            dot.userInteractionEnabled = NO;
        }
        case UIGestureRecognizerStateChanged: {
            for (MMNodeDot *dot in self._nodeDotViews) {
                // If it was already touched, do nothing
                if (!dot.userInteractionEnabled) {
                    continue;
                }
                if (CGRectContainsPoint(dot.frame, location)) {
                    // Make it selected
                    dot.selected = !dot.isSelected;
                    
                    // Disable for futher interaction
                    dot.userInteractionEnabled = NO;
                    
                    [self _updateConnectionLines];
                    // Push animation
//                    CGPoint transl = [gesture translationInView:gesture.view.superview];
//                    if (dot.tag != 99) {
//                        UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[dot] mode:UIPushBehaviorModeInstantaneous];
//                        push.pushDirection = CGVectorMake(-transl.x, -transl.y);
//                        push.magnitude = 0.4f;
//                        [self._nodesAnimator addBehavior:push];
//                    }
//                    dot.tag = 99;
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            for (MMNodeDot *dot in self._nodeDotViews) {
                dot.userInteractionEnabled = YES;
            }
            break;

        default:
            break;
    }
}

@end
