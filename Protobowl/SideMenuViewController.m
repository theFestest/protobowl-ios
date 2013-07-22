//
//  SideMenuViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/20/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "SideMenuViewController.h"
#import "UIView+Donald.h"
#import "LeaderboardCell.h"
#import "ProtobowlUser.h"
#import <QuartzCore/QuartzCore.h>

@interface SideMenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *leaderboard;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leaderboardHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *users;
@end

@implementation SideMenuViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
	    
    // Setup pan gesture to navigate back
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self.mainViewController action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    
    [self.view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.view.layer setShadowOffset:CGSizeMake(0, 6)];
    [self.view.layer setShadowOpacity:0.75];
    [self.view.layer setShadowRadius:10.0];
    
    self.view.layer.shouldRasterize = YES;
    self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [self.leaderboard applyStandardSinkStyle];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) setFullyOnscreen:(BOOL) onscreen
{
    if(onscreen)
    {
        [self.view.layer setShadowOpacity:0.0];
        [self.view.layer setShadowRadius:0.0];
        [self.view.layer setShadowColor:nil];
        
        [self.leaderboard reloadData];
        [self resizeTableView];
        self.view.layer.shouldRasterize = NO;
    }
    else
    {
        [self.view.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [self.view.layer setShadowOffset:CGSizeMake(0, 6)];
        [self.view.layer setShadowOpacity:0.75];
        [self.view.layer setShadowRadius:10.0];
        self.view.layer.shouldRasterize = YES;
    }
}

- (void) resizeTableView
{
    self.leaderboardHeight.constant = self.leaderboard.contentSize.height;
    
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
}

#pragma mark - Table View Delegate Methods
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.users)
    {
        return self.users.count;
    }
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeaderboardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeaderboardCell" forIndexPath:indexPath];
    
    ProtobowlUser *user = self.users[indexPath.row];
    
    cell.rankLabel.text = [NSString stringWithFormat:@"#%d", user.rank];
    cell.scoreLabel.text = [NSString stringWithFormat:@"%d", user.score];
    cell.nameLabel.text = user.name;
    cell.negsLabel.text = [NSString stringWithFormat:@"%d Negs", user.negs];
    
    cell.scoreLabel.backgroundColor = [UIColor greenColor];
    
    // Score ellipse colors:
    // grey: 153,153,153
    // yellow: 248,148,30
    // green: 70,136,71
    // blue: 59, 134, 173
    
    return cell;
}



#pragma mark - Protobowl Leaderboard Delegate Methods
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateUsers:(NSArray *)users
{
    NSLog(@"%@", users);
    
    self.users = users;
    [self.leaderboard reloadData];
    
    [self resizeTableView];
}

@end
