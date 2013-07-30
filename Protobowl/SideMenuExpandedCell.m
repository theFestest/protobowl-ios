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
    if(vc)
    {
        [self.contentView addSubview:vc.view];
        [self.parentVC addChildViewController:vc];
        self.addedVC = vc;
    }
}

@end
