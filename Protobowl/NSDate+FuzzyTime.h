//
//  NSDate+FuzzyTime.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/27/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FuzzyTime)
+ (NSString *)fuzzyTimeSince:(NSDate *)date;
@end
