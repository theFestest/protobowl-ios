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

- (void) setupLayers
{
    //turning off bounds clipping allows the shadow to extend beyond the rect of the view
    [self setClipsToBounds:NO];
    
    //the colors for the gradient.  highColor is at the top, lowColor as at the bottom
    UIColor *highColor = [UIColor colorWithHue:211/360.0 saturation:0.0 brightness:0.6 alpha:1.0];
    UIColor *lowColor = [UIColor colorWithHue:211/360.0 saturation:0.0 brightness:0.5 alpha:1.0];
    
    //The gradient, simply enough.  It is a rectangle
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:[self bounds]];
    [gradient setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil]];
    
    
    // Create the path (with only the top-left corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(6.0, 6.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    gradient.mask = maskLayer;
    
    
    //add the rounded rect layer underneath all other layers of the view
    //[self.layer insertSublayer:roundRect atIndex:0];
    
    //set the shadow on the view's layer
    [self.layer insertSublayer:gradient atIndex:0];
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.layer setShadowOffset:CGSizeMake(0, 6)];
    [self.layer setShadowOpacity:0.75];
    [self.layer setShadowRadius:10.0];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

@end
