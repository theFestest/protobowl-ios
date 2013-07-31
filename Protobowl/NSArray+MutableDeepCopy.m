//
//  NSArray+MutableDeepCopy.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/30/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "NSArray+MutableDeepCopy.h"

@implementation NSArray (MutableDeepCopy)

- (NSArray *) mutableDeepCopy
{
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity: [self count]];
    
    for (id oneValue in self)
    {
    	id oneCopy = nil;
        
        if ([oneValue isKindOfClass:[NSDictionary class]] || [oneValue isKindOfClass:[NSArray class]])
        {
            oneCopy = [oneValue mutableDeepCopy];
        }
        
    	if (oneCopy == nil) // not sure if this is needed
    	{
    		oneCopy = [oneValue copy];
    	}
    	[ret addObject:oneCopy];
    }
    return ret;
}

@end
