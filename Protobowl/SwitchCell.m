//
//  SwitchCell.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/30/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
