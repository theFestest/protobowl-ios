//
//  UIColor+MoreConstructors.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/23/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (MoreConstructors)

+ (UIColor *) colorWithHexValue:(NSString*)hexValue;
+ (UIColor *)colorWithByteRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end