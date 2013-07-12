//
//  PulloutView.m
//  Protobowl
//
//  Created by AppDev on 7/11/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "PulloutView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PulloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayers];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setupLayers];
    }
    return self;
}

- (void) setupLayers
{
    //turning off bounds clipping allows the shadow to extend beyond the rect of the view
    [self setClipsToBounds:NO];
    
    //the colors for the gradient.  highColor is at the top, lowColor as at the bottom
    UIColor *highColor = [UIColor colorWithHue:211/360.0 saturation:0.5 brightness:1.0 alpha:1.0];
    UIColor *lowColor = [UIColor colorWithHue:211/360.0 saturation:1.0 brightness:0.8 alpha:1.0];
    
    //The gradient, simply enough.  It is a rectangle
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:[self bounds]];
    [gradient setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil]];
    
    //the rounded rect, with a corner radius of 6 points.
    //this *does* maskToBounds so that any sublayers are masked
    //this allows the gradient to appear to have rounded corners
    CALayer *roundRect = [CALayer layer];
    [roundRect setFrame:[self bounds]];
    [roundRect setCornerRadius:6.0f];
    [roundRect setMasksToBounds:YES];
    [roundRect addSublayer:gradient];
    
    //add the rounded rect layer underneath all other layers of the view
    [[self layer] insertSublayer:roundRect atIndex:0];
    
    //set the shadow on the view's layer
    [[self layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[self layer] setShadowOffset:CGSizeMake(0, 6)];
    [[self layer] setShadowOpacity:0.75];
    [[self layer] setShadowRadius:10.0];
    [self.layer setCornerRadius:5.0f];
}

@end
