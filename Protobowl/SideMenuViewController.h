//
//  SideMenuViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/20/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@class SideMenuViewController;
@protocol CellViewController <NSObject>

- (float) expandedHeight;
@property (nonatomic, weak) SideMenuViewController *sideMenuViewController;

@end

@interface SideMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) MainViewController *mainViewController;

- (void) setFullyOnscreen:(BOOL) onscreen;
- (void) reloadTableView;
- (void) reloadTableViewAtIndices:(NSArray *)indices numDetailRows:(int)n;

@end