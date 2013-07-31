//
//  NSDictionary+DeepCopy.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/30/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MutableDeepCopy)
- (NSMutableDictionary *) mutableDeepCopy;
@end
