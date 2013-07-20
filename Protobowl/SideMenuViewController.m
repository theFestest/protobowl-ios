//
//  SideMenuViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/20/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "SideMenuViewController.h"

@interface SideMenuViewController ()
@end

@implementation SideMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self.mainViewController action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
}

/*- (void) pan:(UIPanGestureRecognizer *)pan
{
    float dx = [pan translationInView:self.view].x;
    self.panCallback(dx, pan);
    
    [pan setTranslation:CGPointZero inView:self.view];
}*/

@end
