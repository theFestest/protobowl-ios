//
//  LeaderboardCell.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/21/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "LeaderboardCell.h"

@implementation LeaderboardCell

- (void) setToSelfLayout:(BOOL)isSelf
{
    if(isSelf)
    {
        self.nameLabel.hidden = YES;
        self.nameField.hidden = NO;
    }
    else
    {
        self.nameLabel.hidden = NO;
        self.nameField.hidden = YES;
    }
}

@end
