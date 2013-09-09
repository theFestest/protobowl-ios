//
//  SideMenuViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/20/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "SideMenuViewController.h"


@interface PublicRoomsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CellViewController>

@property (nonatomic, weak) MainViewController *mainViewController;

@end