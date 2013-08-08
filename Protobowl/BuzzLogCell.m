//
//  BuzzLogCell.m
//  Protobowl
//
//  Created by Donald Pinckney on 8/3/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "BuzzLogCell.h"

@implementation BuzzLogCell

- (void) hideLeftImage
{
    self.leftImageView.image = nil;
}

- (void) hideRightImage
{
    self.rightImageView.image = nil;
}

- (void) setBuzzLineText:(NSString *)text
{
    BOOL hasLeftImage = NO;
    BOOL hasRightImage = NO;
    NSRange foundRange;
    if((foundRange = [text rangeOfString:kBuzzTag]).location == 0)
    {
        text = [text stringByReplacingCharactersInRange:foundRange withString:@""];
        self.leftImageView.image = [UIImage imageNamed:@"buzz_tag"];
        hasLeftImage = YES;
    }
    else if((foundRange = [text rangeOfString:kBuzzInterruptTag]).location == 0)
    {
        text = [text stringByReplacingCharactersInRange:foundRange withString:@""];
        self.leftImageView.image = [UIImage imageNamed:@"buzz_interrupt_tag"];
        hasLeftImage = YES;
    }
    
    if((foundRange = [text rangeOfString:kBuzzCorrectTag]).location != NSNotFound)
    {
        text = [text stringByReplacingCharactersInRange:foundRange withString:@""];
        self.rightImageView.image = [UIImage imageNamed:@"correct_tag"];
        hasRightImage = YES;
    }
    
    if((foundRange = [text rangeOfString:kBuzzWrongTag]).location != NSNotFound)
    {
        text = [text stringByReplacingCharactersInRange:foundRange withString:@""];
        self.rightImageView.image = [UIImage imageNamed:@"wrong_tag"];
        hasRightImage = YES;
    }
    
    
    
    if(!hasLeftImage)
    {
        [self hideLeftImage];
    }
    if(!hasRightImage)
    {
        [self hideRightImage];
    }
    
    
    self.buzzTextLabel.boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
//    self.buzzTextLabel.backgroundColor = [UIColor redColor];
    
    self.buzzTextLabel.text = text;

}

@end
