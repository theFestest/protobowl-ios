//
//  UIView+ImageSnapshot.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/9/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "UIView+ImageSnapshot.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (ImageSnapshot)

- (UIImage *) imageSnapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
