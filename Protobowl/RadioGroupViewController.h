//
//  RadioGroupViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/31/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RadioGroupViewControllerChangedCallback)(int selection);
typedef void (^RadioGroupViewControllerDoneCallback)();

@interface RadioGroupViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *radioGroupTable;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;

@property (weak, nonatomic) NSArray *options;
@property (nonatomic) int selection;
@property (nonatomic, strong) RadioGroupViewControllerChangedCallback radioChangedCallback;
@property (nonatomic, strong) RadioGroupViewControllerDoneCallback radioDoneCallback;
@end
