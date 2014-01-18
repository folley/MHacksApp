//
//  MMConnectionLine.m
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import "MMConnectionLine.h"
#import "MMStyleSheet.h"

@implementation MMConnectionLine

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[MMStyleSheet sharedInstance] mainGrayColor];
        self.type = MMLineVertical;
    }
    return self;
}

#pragma mark - MMConnectionLine

- (void)connectBetweenView:(UIView *)Aview secondView:(UIView *)BView
{
    [self connectBetweenPoint:Aview.center secondPoint:BView.center];
}

- (void)connectBetweenPoint:(CGPoint)APoint secondPoint:(CGPoint)BPoint
{
    switch (self.type) {
        case MMLineVertical:
            self.frame = CGRectMake(APoint.x,
                                    APoint.y,
                                    2,
                                    BPoint.y - APoint.y);
            break;
        case MMLineHorizontal:
            self.frame = CGRectMake(APoint.x,
                                    APoint.y,
                                    BPoint.x - APoint.x,
                                    1);
            break;
    }
}

@end
