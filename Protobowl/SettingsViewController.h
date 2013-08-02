//
//  SettingsViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/30/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuViewController.h"

@interface SettingsViewController : UIViewController<CellViewController, UITableViewDataSource, UIActionSheetDelegate>

- (void) setupWithPlistPath:(NSString *)path;

@end
