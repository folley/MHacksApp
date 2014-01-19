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
#import "MMStyleSheet.h"
#import <MessageUI/MessageUI.h>
#import "UIView+JMNoise.h"
#import "MMProfilePhotoCheckBox.h"

#define DAYS 5
#define HOURS 5

@interface MMDatePickerViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIDynamicAnimator *_nodesAnimator;
@property (nonatomic, strong) UIDynamicAnimator *_avatarsAnimator;

@property (nonatomic, strong) NSMutableArray *_nodeDotViews;
@property (nonatomic, strong) NSArray *_dateDotViews;
@property (nonatomic, strong) NSMutableArray *_nodesConnectionLines;
@property (nonatomic, strong) NSArray *_people;

@property (nonatomic, strong) NSMutableArray *_currentlyPresentedAvatars;
@property (nonatomic, weak) MMNodeDot *_expandedNodeDot;

@property (nonatomic, strong) MMPerson *_myPerson;
@property (nonatomic, strong) NSMutableArray *_otherShitViews;
@property (nonatomic, strong) UIView *noiseBG;
@property (nonatomic, strong) NSMutableArray *_avatars;

@property BOOL focusFinished;

@end

@implementation MMDatePickerViewController

int tab[7][7];

- (instancetype)initWithMainPerson:(MMPerson *)myPerson people:(NSArray *)people
{
    if (self = [super init]) {
        self._myPerson = myPerson;
        self._people = people;
    }
    return self;
}

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
                
                if ([[person.parseObject objectId] isEqualToString:@"MAqQNyRsJj"]) {
                    self._myPerson = person;
                }
            }
            self._people = [allPeople mutableCopy];
            [self _addPeopleAvatars];
            
            [self _configureNodesAppearance];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _noiseBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1100, 1000)];
    _noiseBG.backgroundColor = [[MMStyleSheet sharedInstance] mainLightGrayColor];
    [_noiseBG applyNoise];
    
    for (int i=0; i<5; i++) {
        for (int j=0; j<5; j++) {
            tab[i][j] = 0;
        }
    }
    
    [self.view addSubview:_noiseBG];
    self.focusFinished = NO;
    
    __nodeDotViews = [[NSMutableArray alloc] init];
    __nodesConnectionLines = [[NSMutableArray alloc] init];
    __currentlyPresentedAvatars = [[NSMutableArray alloc] init];
 __otherShitViews = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [[MMStyleSheet sharedInstance] mainLightGrayColor];
    
    // People
    [self _addPeopleAvatars];

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
        
        MMDateDot *dateDot = [[MMDateDot alloc] initWithFrame:CGRectMake(0, 0, 105, 105)];
        dateDot.dateLabel.text = [NSString stringWithFormat:@"%i", 15 + i];
        dateDot.dayLabel.text = [((NSString *)[weekdaysNames objectAtIndex:i]).uppercaseString substringToIndex:3];
        dateDot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100, 1./100);
        dateDot.center = CGPointMake(240 + 140 * dotDay, 130);
        [dateDots addObject:dateDot];
        [self.view addSubview:dateDot];
    }
    __dateDotViews = [dateDots mutableCopy];
    
    // Set up dots
    for (NSInteger i=0; i<[__nodeDotViews count]; i++) {
        // Add dots to a view
        MMNodeDot *dot = __nodeDotViews[i];
        dot.center = [((MMDateDot *)dateDots[i % DAYS]) center];
        dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100, 1./100);
        [self.view insertSubview:dot atIndex:1];
        
        
        // Double gesture
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(_handleDoubleTapGesture:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [dot addGestureRecognizer:doubleTapGesture];
        
        // Add tap gesture recognizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(_handleTapGestureOnDot:)];
        [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
        [dot addGestureRecognizer:tapGesture];
        
        // Pan gesture
        UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(_handlePanGesture:)];
        [dot addGestureRecognizer:swipeGesture];
        
    }

    
    // Set up animator
    self._nodesAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self._avatarsAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    
    [self _addRestButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self performSelector:@selector(_showDaysDots) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(_animateDotsToCorrectPositions) withObject:nil afterDelay:1.6];
    [self performSelector:@selector(_connectDots) withObject:nil afterDelay:2.2];
    [self performSelector:@selector(_addHoursLables) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(_addHorizontalLines) withObject:nil afterDelay:2.0];
    [self _configureNodesAppearance];
}

#pragma mark - MMDatePickerViewController ()

- (void)_focusOnBest
{
    [self _countBestHours];
}

- (void)_countBestHours
{
    for (MMPerson *person in self._people) {
        NSArray *rankedHours = person.rankedHours;

        NSLog(@"%@", rankedHours);
        for (int i=0 ; i<MIN(DAYS, rankedHours.count) ; i++) {
            for (NSNumber *number in rankedHours[i]) {
                tab[i][number.integerValue]++;
            }
        }
    }
    
    NSMutableArray *targets = [NSMutableArray new];
    
    int max = 0;
    
    for (NSInteger j=0; j<HOURS; j++) {
        for (NSInteger i=0; i<DAYS; i++) {
            if (tab[i][j] > max) {
                max = tab[i][j];
            }
        }
    }
    
    for (NSInteger j=0; j<HOURS; j++) {
        for (NSInteger i=0; i<DAYS; i++) {
            if (tab[i][j] >= max) {
                NSInteger nodeDotIndex = i + DAYS*j;
                [targets addObject:self._nodeDotViews[nodeDotIndex]];
            }
        }
    }
    
    [self _explodeNodesExcept:targets];

}

- (BOOL)table:(NSArray *)table contains:(MMNodeDot *)dot
{
    for (MMNodeDot *nextDot in table) {
        if (nextDot == dot) {
            return YES;
        }
    }
    return NO;
}

- (void)_explodeNodesExcept:(NSArray *)chosenNodes
{
    NSMutableArray *particles = [[NSMutableArray alloc] initWithCapacity:50];
    [self._nodesAnimator removeAllBehaviors];
    
    MMNodeDot *selectedNode;
    if (chosenNodes[0]) {
        selectedNode = chosenNodes[0];
    }
    
    for (MMNodeDot *node in self._nodeDotViews) {
        if ([self table:chosenNodes contains:node]) {
            continue;
        }
        
        // Create particles
        for (NSInteger i=0; i<5; i++) {
            UIView *particle = [[UIView alloc] init];
            particle.frame = CGRectMake(0, 0, selectedNode.frame.size.width/2, selectedNode.frame.size.height/2);
            particle.center = [node.superview convertPoint:node.center
                                                    toView:self.view];
            particle.backgroundColor = node._dotView.backgroundColor;
            particle.layer.cornerRadius = particle.frame.size.width/2.f;
            particle.clipsToBounds = YES;
            [self.view addSubview:particle];
            
            [particles addObject:particle];
            
            node.alpha = 0.;
            
            
            CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
            anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            anim1.fromValue = [NSNumber numberWithFloat:particle.layer.cornerRadius];
            anim1.toValue = [NSNumber numberWithFloat:0.0f];
            anim1.duration = 2;
            [particle.layer addAnimation:anim1 forKey:@"cornerRadius"];
            
            
            // Push
            UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[particle]
                                                                    mode:UIPushBehaviorModeInstantaneous];
            CGFloat randomX = 1. / (rand() % 200 + 100);
            CGFloat randomY = 1. / (rand() % 200 + 100);
            NSInteger randomSignX = rand() % 2 == 0 ? 1 : -1;
            NSInteger randomSignY = rand() % 2 == 0 ? 1 : -1;
            push.pushDirection = CGVectorMake(randomX * randomSignX,
                                              randomY * randomSignY);
            push.magnitude = 0.15;
            [self._nodesAnimator addBehavior:push];
            
            [UIView animateWithDuration:1.6 animations:^{
                particle.alpha = 0.f;
                particle.frame = CGRectMake(particle.frame.origin.x, particle.frame.origin.y, 0, 0);
            }];
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        for (UIView *view in self._nodesConnectionLines) {
            view.alpha = 0.f;
        }
        
        for (UIView *view in self._dateDotViews) {
            view.alpha = 0.f;
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100., 1./100.);
        }
        
        for (UIView *view in self._otherShitViews) {
            view.alpha = 0.f;
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100., 1./100.);
        }
    }];
    
    
    [UIView animateWithDuration:1.0 animations:^{
            for (MMNodeDot *dot in chosenNodes) {
                dot._dotView.backgroundColor = [[MMStyleSheet sharedInstance] greenColor];
            }
        } completion:^(BOOL finished) {
            
            UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [confirmButton setTitle:@"tap on green button to send confirmation" forState:UIControlStateNormal];
            [confirmButton sizeToFit];
            [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [confirmButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            confirmButton.center = CGPointMake(self.view.frame.size.height/2.f,
                                               self.view.frame.size.width/2.f + 60);
            [confirmButton addTarget:self action:@selector(_sendConfirmation) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:confirmButton];
            self.focusFinished = YES;
    }];
}

- (void)_addPeopleAvatars
{
    if (!self._avatars) {
        self._avatars = [[NSMutableArray alloc] init];
    }

    UIView *sidebarBg = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-100,
                                                                 0,
                                                                 100,
                                                                 self.view.frame.size.height)];
    sidebarBg.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    sidebarBg.backgroundColor = [UIColor colorWithWhite:1. alpha:.8];
    [self.view addSubview:sidebarBg];
    
    for (NSInteger i=0; i<[self._people count]; i++) {
        MMPerson *person = self._people[i];
        UIImageView *avatarView = [[UIImageView alloc] initWithImage:person.avatarImage];
        [self._avatars addObject:avatarView];
        avatarView.frame = CGRectMake(0, 0, 45, 45);
        avatarView.layer.cornerRadius = avatarView.frame.size.width/2.f;
        avatarView.clipsToBounds = YES;
        avatarView.center = CGPointMake(sidebarBg.bounds.size.width - 50,
                                        200 + 100*i);
        avatarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [sidebarBg addSubview:avatarView];
        
        // tap gesture
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = avatarView.frame;
        btn.backgroundColor = [UIColor clearColor];
        [sidebarBg addSubview:btn];
        btn.tag = i;
        [btn addTarget:self action:@selector(_switchUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIButton *focusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [focusButton setTitle:@"FOCUS" forState:UIControlStateNormal];
    [focusButton setTitleColor:[[MMStyleSheet sharedInstance] greenColor] forState:UIControlStateNormal];
    [focusButton setTitleColor:[[MMStyleSheet sharedInstance] mainDarkGrayColor] forState:UIControlStateDisabled];
    [focusButton sizeToFit];
    [focusButton addTarget:self action:@selector(_focusOnBest) forControlEvents:UIControlEventTouchUpInside];
    focusButton.frame = CGRectMake(00,
                                   645,
                                   100,
                                   200);
    focusButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sidebarBg addSubview:focusButton];
    
    [self _configureAvatarAppearance];
}

- (void)_switchUser:(UIButton *)sender
{
    
    MMDatePickerViewController *pickerVC = [[MMDatePickerViewController alloc] initWithMainPerson:self._people[sender.tag]
                                                                                           people:self._people];
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pickerVC animated:YES completion:nil];
    }];
}

- (void)_configureAvatarAppearance
{
    for (NSInteger i=0; i<[self._people count]; i++) {
        MMPerson *person = self._people[i];
        
        BOOL alreadyVoted = NO;
        for (NSArray *array in person.rankedHours) {
            if ([array count] != 0) {
                alreadyVoted = YES;
                break;
            }
        }

        [UIView animateWithDuration:0.3 animations:^{
            if (!alreadyVoted) {
                [self._avatars[i] setAlpha:0.5];
            }
            else {
                [self._avatars[i] setAlpha:1.f];
            }
            
            if (person == self._myPerson) {
                [(UIView *)self._avatars[i] setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5)];
            }
            else {
                [(UIView *)self._avatars[i] setTransform:CGAffineTransformIdentity];
            }
        }];
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
        [self._otherShitViews addObject:line];
        line.alpha = 0.f;
        [self.view insertSubview:line atIndex:1];
        
        CGPoint dateDotAnchor = CGPointMake(((MMDateDot *)self._dateDotViews[i]).center.x,
                                            ((MMDateDot *)self._dateDotViews[i]).frame.origin.y +
                                            ((MMDateDot *)self._dateDotViews[i]).frame.size.height);
        
        [line connectBetweenPoint:dateDotAnchor
                      secondPoint:((MMNodeDot *)self._nodeDotViews[i]).center];
        
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
            [self.view insertSubview:line atIndex:1];
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
                                        230 + 100 * dotHour);
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
        [self._otherShitViews addObject:hourLabel];
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
        [self._otherShitViews addObject:line];
        line.type = MMLineHorizontal;
        line.alpha = 0.3f;
        [self.view insertSubview:line atIndex:1];
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


- (void)_showVotersFromNode:(MMNodeDot *)node
{
    NSInteger nodeDay = node.tag % DAYS;
    NSInteger nodeHour = node.tag / DAYS;
    // Find voters of this node
    NSMutableArray *voters = [[NSMutableArray alloc] init];
    for (MMPerson *person in self._people) {
        if ([person.rankedHours[nodeDay] containsObject:@(nodeHour)]) {
            [voters addObject:person];
        }
    }
    
    self._expandedNodeDot = node;
    
    for (NSInteger i=0; i<[voters count]; i++) {
        MMPerson *person = voters[i];
        UIImageView *avatarView = [[UIImageView alloc] initWithImage:person.avatarImage];
        [self._currentlyPresentedAvatars addObject:avatarView];
        
        avatarView.frame = CGRectMake(0, 0, 50, 50);
        avatarView.layer.cornerRadius = avatarView.frame.size.width/2.f;
        avatarView.clipsToBounds = YES;
        avatarView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.f/100.f, 1.f/100.f);
        [self.view addSubview:avatarView];
        
        CGFloat angleOffset = 2*M_PI / [voters count] * i;
        CGFloat const RADIUS = 50;
        CGFloat yOffset = sinf(2*M_PI - angleOffset) * RADIUS;
        CGFloat xOffset = cosf(2*M_PI - angleOffset) * RADIUS;
        
        avatarView.center = node.center;
        
        // Animation
        [UIView animateWithDuration:0.3 animations:^{
            avatarView.transform = CGAffineTransformIdentity;
        }];
        
        CGPoint snapPoint = CGPointMake(node.center.x + xOffset,
                                        node.center.y + yOffset);
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:avatarView snapToPoint:snapPoint];
        snap.damping = 0.3;
        [self._avatarsAnimator addBehavior:snap];
    }
}

- (void)_configureNodesAppearance
{
    for (NSInteger day=0; day<[self._myPerson.rankedHours count]; day++) {
        NSArray *dayHours = self._myPerson.rankedHours[day];
        for (NSNumber *hourIndex in dayHours) {
            ((MMNodeDot *)self._nodeDotViews[day + [hourIndex integerValue] * DAYS]).selected = YES;
        }
    }
}

- (void)_sendConfirmation
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@"Let's meet!"];
    [mailComposer setMessageBody:@"Hey guys! We've just chosen the best time for our meeting!" isHTML:NO];
    
    NSMutableArray *mails = [[NSMutableArray alloc] init];
    for (MMPerson *person in self._people) {
        [mails addObject:person.parseObject[@"email"]];
    }
    [mailComposer setToRecipients:mails];
    
    [self presentViewController:mailComposer animated:YES completion:nil];
}


- (void)resetData:(id)sender
{
    for (MMPerson *person in self._people) {
        person.rankedHours = @[@[], @[], @[], @[], @[]];
        person.parseObject[@"rankedHours"] = person.rankedHours;
        [person.parseObject saveInBackground];
    }

    
    for (MMNodeDot *node in self._nodeDotViews) {
        node.selected = NO;
    }
    [self _updateConnectionLines];
}c

- (void)_addRestButton
{
    UIButton *xButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    [xButton setTitle:@"X" forState:UIControlStateNormal];
    [xButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [xButton addTarget:self
                action:@selector(resetData:)
      forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:xButton];
}

#pragma mark - Gesture Handlers

- (void)_updateRankedHoursWithNodeDot:(MMNodeDot *)nodeDot
{
    NSArray *rankedHours = self._myPerson.parseObject[@"rankedHours"];
    NSMutableArray *newRankedHours = [[NSMutableArray alloc] initWithArray:rankedHours];
    NSMutableArray *hoursOfDay = [[NSMutableArray alloc] initWithArray:newRankedHours[nodeDot.tag % DAYS]];
    if (nodeDot.selected) {
        if (![hoursOfDay containsObject:@(nodeDot.tag / DAYS)]) {
            [hoursOfDay addObject:@(nodeDot.tag / DAYS)];
        }
    }
    else {
        [hoursOfDay removeObject:@(nodeDot.tag / DAYS)];
    }
    [newRankedHours replaceObjectAtIndex:(nodeDot.tag % DAYS) withObject:[hoursOfDay mutableCopy]];
    
    self._myPerson.rankedHours = [newRankedHours mutableCopy];
    self._myPerson.parseObject[@"rankedHours"] = [newRankedHours mutableCopy];
    [self._myPerson.parseObject saveInBackground];
    
    //
    [self _configureAvatarAppearance];
}

- (void)_handleTapGestureOnDot:(UITapGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateRecognized: {
            
            NSInteger tappedDotIndex = gesture.view.tag;
            MMNodeDot *tappedDot = self._nodeDotViews[tappedDotIndex];
            
            if (self.focusFinished == YES) {
                [self performSelector:@selector(_sendConfirmation) withObject:Nil afterDelay:0];

                break;
            }
            
            tappedDot.selected = !tappedDot.isSelected;
            
            [self _updateRankedHoursWithNodeDot:tappedDot];
            [self _updateConnectionLines];
        }
            break;
        default:
            break;
    }
}

- (void)_handleDoubleTapGesture:(UITapGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateRecognized: {
            NSInteger tappedDotIndex = gesture.view.tag;
            MMNodeDot *tappedDot = self._nodeDotViews[tappedDotIndex];
            [self _showVotersFromNode:tappedDot];
        }
            break;
            
        default:
            break;
    }
}

- (void)_dismissVisibleAvatars
{
    [self._avatarsAnimator removeAllBehaviors];
    for (UIView *view in self._currentlyPresentedAvatars) {
        [UIView animateWithDuration:0.3 animations:^{
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.f/100.f, 1.f/100.f);
            view.center = self._expandedNodeDot.center;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    
    [self._currentlyPresentedAvatars removeAllObjects];
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view.superview];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            MMNodeDot *dot = ((MMNodeDot *)gesture.view);
            dot.selected = !dot.isSelected;
            [self _updateRankedHoursWithNodeDot:dot];
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
                    [self _updateRankedHoursWithNodeDot:dot];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self _dismissVisibleAvatars];
}

#pragma mark - <MFMailComposerViewControllerDelegate>

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
