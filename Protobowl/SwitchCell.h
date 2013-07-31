//
//  SwitchCell.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/30/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
