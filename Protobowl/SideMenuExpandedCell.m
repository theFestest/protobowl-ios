//
//  SideMenuExpandedCell.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/29/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "SideMenuExpandedCell.h"

@interface SideMenuExpandedCell ()

@end

@implementation SideMenuExpandedCell

- (void) setViewController:(UIViewController<CellViewController> *)vc
{    
    [self.addedVC removeFromParentViewController];
    [self.addedVC.view removeFromSuperview];
    self.addedVC = nil;
    
    [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(vc)
    {
        UIView *mainView = vc.view;
        [self.contentView addSubview:mainView];
        [self.parentVC addChildViewController:vc];
        self.addedVC = vc;
        
        mainView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mainView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(mainView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(mainView)]];
    }
}

@end
