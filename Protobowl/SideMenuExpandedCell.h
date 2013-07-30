//
//  SideMenuExpandedCell.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/29/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuViewController.h"

@interface SideMenuExpandedCell : UITableViewCell
- (void) setViewController:(UIViewController<CellViewController> *)vc;
@property (nonatomic, strong) UIViewController *parentVC;
@property (weak, nonatomic) UIViewController<CellViewController> *addedVC;

@end
