//
//  LeaderboardDetailCell.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/25/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CapsuleLabel.h"

@interface LeaderboardDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet CapsuleLabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameField;

- (void) setToSelfLayout:(BOOL)isSelf;
@end
