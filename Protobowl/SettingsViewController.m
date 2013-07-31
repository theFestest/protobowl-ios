//
//  SideMenuViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/20/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIView+Donald.h"
#import "UIColor+MoreConstructors.h"
#import <QuartzCore/QuartzCore.h>

#define kLeaderboardCellHeight 44
#define kLeaderboardDetailCellHeight 180

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;


@end

@implementation SettingsViewController
@synthesize sideMenuViewController;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.sideMenuViewController reloadTableView];
    self.containerView.exclusiveTouch = YES;
    
    UITapGestureRecognizer *fakeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fakeTapAction)]; // Add a tap gesture recognizer which does nothing so it overrides the tap gesture on the outer cell.
    [self.containerView addGestureRecognizer:fakeTap];
}

- (void) fakeTapAction
{
    
}

- (float) expandedHeight
{
    return 480;
}

@end