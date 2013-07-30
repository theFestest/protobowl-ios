//
//  SideMenuExpandedCell.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/29/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuExpandedCell : UITableViewCell
- (void) setViewController:(UIViewController *)vc;
@property (nonatomic, strong) IBOutlet UIViewController *parentVC;
@end
