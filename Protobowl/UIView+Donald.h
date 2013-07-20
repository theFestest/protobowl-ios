//
//  UIView+ImageSnapshot.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/9/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Donald)

- (UIImage *) imageSnapshot;

- (void) applySinkStyleWithInnerColor:(UIColor *)innerColor borderColor:(UIColor *)borderColor borderWidth:(float)width andCornerRadius:(float)radius;

@end
