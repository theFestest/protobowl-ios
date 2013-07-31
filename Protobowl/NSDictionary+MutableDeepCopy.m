//
//  NSDictionary+DeepCopy.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/30/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "NSDictionary+MutableDeepCopy.h"

@implementation NSDictionary (MutableDeepCopy)

- (NSMutableDictionary *) mutableDeepCopy
{
    NSMutableDictionary * ret = [[NSMutableDictionary alloc] initWithCapacity: [self count]];
    NSArray *keys = [self allKeys];
    
    for (id key in keys)
    {
    	id oneValue = [self valueForKey:key]; // should return the array
    	id oneCopy = nil;
        
        if ([oneValue isKindOfClass:[NSDictionary class]] || [oneValue isKindOfClass:[NSArray class]])
        {
            oneCopy = [oneValue mutableDeepCopy];
        }
        
    	if (oneCopy == nil) // not sure if this is needed
    	{
    		oneCopy = [oneValue copy];
    	}
    	[ret setValue:oneCopy forKey:key];
        
    	//[oneCopy release];
    }
    return ret;
}

@end
