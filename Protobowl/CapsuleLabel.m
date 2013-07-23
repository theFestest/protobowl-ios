//
//  CapsuleLabel.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/23/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "CapsuleLabel.h"
#import "UIColor+MoreConstructors.h"
#import <QuartzCore/QuartzCore.h>

@implementation CapsuleLabel

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setupCorners];
        [self resize];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setupCorners];
        [self resize];
    }
    return self;
}

- (void) setupCorners
{
    CGSize fontSize = [@"30" sizeWithFont:self.font];
    self.layer.cornerRadius = fontSize.height/2;
}

- (void) resize
{
    self.textAlignment = NSTextAlignmentCenter;
    
    CGRect frame = self.frame;
    CGSize size = [self intrinsicContentSize];
    frame.size = size;
    self.frame = frame;
}

- (void) setFont:(UIFont *)font
{
    [super setFont:font];
    [self resize];
    [self setupCorners];
}

- (void) setText:(NSString *)text
{
    [super setText:text];
    self.textColor = [UIColor whiteColor];
    
    [self resize];
}

- (void) setStatusColor:(StatusColor)color
{
    // Score ellipse colors:
    // grey: 153,153,153
    // yellow: 248,148,30
    // green: 70,136,71
    // blue: 59, 134, 173
    if(color == StatusColorOnline)
    {
        self.backgroundColor = [UIColor colorWithByteRed:70 green:136 blue:71 alpha:255];
    }
    else if(color == StatusColorOffline)
    {
        self.backgroundColor = [UIColor colorWithByteRed:153 green:153 blue:153 alpha:255];
    }
    else if(color == StatusColorSelf)
    {
        self.backgroundColor = [UIColor colorWithByteRed:59 green:134 blue:173 alpha:255];
    }
    else if(color == StatusColorIdle)
    {
        self.backgroundColor = [UIColor colorWithByteRed:248 green:148 blue:30 alpha:255];
    }
}


- (CGSize) intrinsicContentSize
{
    CGSize s = [super intrinsicContentSize];
    s.width += 20;
    return s;
}

@end
