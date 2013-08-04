//
//  BuzzLogCell.h
//  Protobowl
//
//  Created by Donald Pinckney on 8/3/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASUILabel.h"

@interface BuzzLogCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet ASUILabel *buzzTextLabel;
@property (nonatomic, weak) IBOutlet UIImageView *rightImageView;

- (void) setBuzzLineText:(NSString *)text; // Pass in the whole line of text, including the [BUZZ], etc.

@end
