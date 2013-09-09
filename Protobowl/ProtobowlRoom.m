//
//  ProtobowlRoom.m
//  Protobowl
//
//  Created by Donald Pinckney on 9/8/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "ProtobowlRoom.h"

@implementation ProtobowlRoom

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ - %d online", self.name, self.numberActive];
}
@end
