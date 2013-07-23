//
//  LeaderboardCell.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/21/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CapsuleLabel.h"

@interface LeaderboardCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet CapsuleLabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
