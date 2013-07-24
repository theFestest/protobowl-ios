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
#import "UIColor+MoreConstructors.h"
#import <QuartzCore/QuartzCore.h>

@interface SideMenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *leaderboard;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leaderboardHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *users;

@property (nonatomic) int selectedRow;
@end

@implementation SideMenuViewController

- (void) reloadLeaderboard
{
    [self.leaderboard reloadData];
    [self resizeTableView];
}

- (void) reloadLeaderboardAtIndices:(NSArray *)indices
{
    [self.leaderboard reloadRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationAutomatic];
    [self resizeTableView];
}

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
    
    self.selectedRow = -1;
}


- (void) setFullyOnscreen:(BOOL) onscreen
{
    if(onscreen)
    {
        [self.view.layer setShadowOpacity:0.0];
        [self.view.layer setShadowRadius:0.0];
        [self.view.layer setShadowColor:nil];
        
        [self reloadLeaderboard];
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
    [cell.scoreLabel setUserStatus:user.status];
    cell.nameLabel.text = user.name;
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.selectedRow)
    {
        return 200;
    }
    return 44;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected");
    self.selectedRow = indexPath.row;
    [self reloadLeaderboardAtIndices:[NSArray arrayWithObject:indexPath]];
}


- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Deselected");
}


#pragma mark - Protobowl Leaderboard Delegate Methods
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateUsers:(NSArray *)users
{
    NSLog(@"%@", users);
    
    self.users = users;
    
    [self reloadLeaderboard];
}

@end
