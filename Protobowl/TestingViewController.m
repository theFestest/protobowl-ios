//
//  TestingViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 6/13/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "TestingViewController.h"

@interface TestingViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation TestingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 2000);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
