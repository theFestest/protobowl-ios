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
    
    NSArray *symbols = [NSThread callStackSymbols];
    
    if(selected)
    {
        if(symbols.count >= 2)
        {
            NSString *caller = symbols[1]; // Very sketch solution to the multiple calls of this method...
            if([caller rangeOfString:@"_selectAllSelectedRows"].location == NSNotFound)
            {
                self.callback(self);
                [self setSelected:NO animated:animated];
            }
        }
    }
}

@end
