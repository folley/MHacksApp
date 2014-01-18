//
//  MMConnectionLine.h
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, MMLineType) {
    MMLineHorizontal,
    MMLineVertical
};

@interface MMConnectionLine : UIView

@property (nonatomic) BOOL highlighted;
@property (nonatomic) MMLineType type;

- (void)connectBetweenView:(UIView *)Aview secondView:(UIView *)BView;
- (void)connectBetweenPoint:(CGPoint)APoint secondPoint:(CGPoint)BPoint;

@end
