//
//  ProtobowlUser.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/21/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "ProtobowlUser.h"

@implementation ProtobowlUser

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@: {score=%d, rank=%d, negs=%d, userID=%@}", self.name, self.score, self.rank, self.negatives, self.userID];
}

- (NSString *) debugDescription
{
    return [self description];
}
@end
