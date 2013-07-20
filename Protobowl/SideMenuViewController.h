//
//  SideMenuViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/20/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

//typedef void (^SideMenuPanCallback)(UIPanGestureRecognizer *pan);

@interface SideMenuViewController : UIViewController

@property (nonatomic, weak) ViewController *mainViewController;

@end