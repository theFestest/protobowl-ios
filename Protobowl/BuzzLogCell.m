//
//  BuzzLogCell.m
//  Protobowl
//
//  Created by Donald Pinckney on 8/3/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "BuzzLogCell.h"

@interface BuzzLogCell ()
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftImageWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightImageWidthConstraint;

@end

@implementation BuzzLogCell

- (void) hideLeftImage
{
    self.leftImageView.image = [UIImage imageNamed:@"nothing_image"];
}

- (void) hideRightImage
{
    self.rightImageView.image = [UIImage imageNamed:@"nothing_image"];
}

- (void) setBuzzLineText:(NSString *)text
{
    BOOL hasLeftImage = NO;
    BOOL hasRightImage = NO;
    NSRange foundRange;
    
    if((foundRange = [text rangeOfString:kBuzzPromptTag]).location != NSNotFound && foundRange.location != 0)
    {
        text = [text stringByReplacingCharactersInRange:foundRange withString:@""];
        self.rightImageView.image = [UIImage imageNamed:@"prompt_tag"];
        hasRightImage = YES;
    }
    
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
    else if((foundRange = [text rangeOfString:kBuzzPromptTag]).location == 0)
    {
        text = [text stringByReplacingCharactersInRange:foundRange withString:@""];
        self.leftImageView.image = [UIImage imageNamed:@"prompt_tag"];
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
    
    self.buzzTextLabel.boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    self.buzzTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    
    self.buzzTextLabel.text = text;
}

@end
