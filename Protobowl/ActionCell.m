//
//  ActionCell.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/30/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "ActionCell.h"

@implementation ActionCell

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        self.callback(self);
        [self setSelected:NO animated:YES];
    }
}

@end
