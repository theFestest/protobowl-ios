//
//  UIView+ImageSnapshot.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/9/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "UIView+Donald.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Donald)

- (UIImage *) imageSnapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void) applySinkStyleWithInnerColor:(UIColor *)innerColor borderColor:(UIColor *)borderColor borderWidth:(float)width andCornerRadius:(float)radius
{
    if(innerColor) self.backgroundColor = innerColor;
    if(borderColor) self.layer.borderColor = [borderColor CGColor];
    
    self.layer.borderWidth = width;
    self.layer.cornerRadius = 10.0;
}

@end
