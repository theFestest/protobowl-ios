//
//  ActionCell.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/30/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActionCell;
typedef void (^ActionCellCallback)(ActionCell *actionCell);

@interface ActionCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) ActionCellCallback callback;
@end
