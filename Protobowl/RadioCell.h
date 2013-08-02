//
//  RadioCell.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/30/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RadioChangedCallback)(int selection);

@interface RadioCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) NSArray *options;
@property (nonatomic) int selection;
@property (nonatomic, strong) RadioChangedCallback radioChangedCallback;
@property (nonatomic, weak) UIViewController *referenceViewController;
@property (nonatomic, strong) NSString *keyPath;
@end
