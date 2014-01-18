//
//  MMDateDot.h
//  MMMhacksApp
//
//  Created by Michal Smialko on 1/18/14.
//  Copyright (c) 2014 lobodzinski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNodeDot : UIView

@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, strong) NSArray *connectedNodes;

@end
