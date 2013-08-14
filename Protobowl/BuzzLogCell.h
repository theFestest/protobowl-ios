//
//  BuzzLogCell.h
//  Protobowl
//
//  Created by Donald Pinckney on 8/3/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPLabel.h"

#define kBuzzTag @"[BUZZ]"
#define kBuzzInterruptTag @"[BUZZ_INTERRUPT]"
#define kBuzzCorrectTag @"[CORRECT]"
#define kBuzzWrongTag @"[WRONG]"
#define kBuzzPromptTag @"[PROMPT]"


@interface BuzzLogCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet DPLabel *buzzTextLabel;
@property (nonatomic, weak) IBOutlet UIImageView *rightImageView;

- (void) setBuzzLineText:(NSString *)text; // Pass in the whole line of text, including the [BUZZ], etc.

@end
