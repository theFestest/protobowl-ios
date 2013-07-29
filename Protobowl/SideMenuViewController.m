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
#import "LeaderboardDetailCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+FuzzyTime.h"

#define kLeaderboardCellHeight 44
#define kLeaderboardDetailCellHeight 180

@interface SideMenuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *leaderboardTitle;
@property (weak, nonatomic) IBOutlet UITableView *leaderboard;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leaderboardHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *users;

@property (nonatomic) NSString *selectedUserID;

@property (nonatomic, strong) UITextField *activeField;
@end

@implementation SideMenuViewController

- (void) reloadLeaderboard
{
    [self.leaderboard reloadData];
    [self resizeTableView];
}

- (void) reloadLeaderboardAtIndices:(NSArray *)indices numDetailRows:(int)n
{
    float targetHeight = kLeaderboardCellHeight * ([self tableView:self.leaderboard numberOfRowsInSection:[indices[0] section]] - n) + kLeaderboardDetailCellHeight * n;
    self.leaderboard.contentSize = CGSizeMake(self.leaderboard.contentSize.width, targetHeight);
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
    
    self.selectedUserID = nil;
    
    [self registerForKeyboardNotifications];
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
    NSLog(@"Resizing!");
    CGRect frame = self.leaderboard.frame;
    frame.size.height = self.leaderboard.contentSize.height;
    self.leaderboardHeight.constant = self.leaderboard.contentSize.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.leaderboard.frame = frame;
    }];
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
    ProtobowlUser *user = self.users[indexPath.row];
    
    if([user.userID isEqual:self.selectedUserID])
    {
        LeaderboardDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeaderboardDetailCell" forIndexPath:indexPath];
        
        
        cell.rankLabel.text = [NSString stringWithFormat:@"#%d", user.rank];
        cell.scoreLabel.text = [NSString stringWithFormat:@"%d", user.score];
        [cell.scoreLabel setUserStatus:user.status];
        
        cell.correctsLabel.text = [NSString stringWithFormat:@"%d", user.corrects];
        cell.negativesLabel.text = [NSString stringWithFormat:@"%d", user.negatives];
        cell.bestStreakLabel.text = [NSString stringWithFormat:@"%d", user.bestStreak];
        
        if(user.status == ProtobowlUserStatusOffline)
        {
            NSDate *lastOnlineDate = [NSDate dateWithTimeIntervalSince1970:user.lastTimeOnline];
            cell.lastSeenLabel.text = [NSDate fuzzyTimeSince:lastOnlineDate];
        }
        else
        {
            cell.lastSeenLabel.text = @"Right Now!";
        }
        
        if([user.userID isEqualToString:self.mainViewController.manager.myself.userID])
        {
            [cell setToSelfLayout:YES];
            cell.nameField.text = user.name;
        }
        else
        {
            [cell setToSelfLayout:NO];
            cell.nameLabel.text = user.name;
        }
        
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        return cell;
    }
    else
    {
        LeaderboardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeaderboardCell" forIndexPath:indexPath];
        
        ProtobowlUser *user = self.users[indexPath.row];
        
        cell.rankLabel.text = [NSString stringWithFormat:@"#%d", user.rank];
        cell.scoreLabel.text = [NSString stringWithFormat:@"%d", user.score];
        [cell.scoreLabel setUserStatus:user.status];
        
        if([user.userID isEqualToString:self.mainViewController.manager.myself.userID])
        {
            [cell setToSelfLayout:YES];
            cell.nameField.text = user.name;
        }
        else
        {
            [cell setToSelfLayout:NO];
            cell.nameLabel.text = user.name;
        }
        
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        return cell;
    }
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProtobowlUser *user = self.users[indexPath.row];
    
    if([user.userID isEqual:self.selectedUserID])
    {
        return kLeaderboardDetailCellHeight;
    }
    return kLeaderboardCellHeight;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected");
    
    NSString *userID = [self.users[indexPath.row] userID];
    
    NSIndexPath *lastSelected = [self indexPathForUserID:self.selectedUserID];
    self.selectedUserID = userID;
    if([lastSelected isEqual:indexPath])
    {
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
    else if(lastSelected)
    {
        [self reloadLeaderboardAtIndices:@[lastSelected, indexPath] numDetailRows:1];
    }
    else
    {
        [self reloadLeaderboardAtIndices:@[indexPath] numDetailRows:1];
    }
}


- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Deselected");
    self.selectedUserID = nil;
    [self reloadLeaderboardAtIndices:@[indexPath] numDetailRows:0];
}


- (int) countActiveUsers:(NSArray *)users
{
    int count = 0;
    for (ProtobowlUser *user in users)
    {
        if(user.status == ProtobowlUserStatusOnline || user.status == ProtobowlUserStatusSelf) count++;
    }
    return count;
}


- (NSIndexPath *) indexPathForUserID:(NSString *) userID
{
    for(int i = 0; i < self.users.count; i++)
    {
        if([[self.users[i] userID] isEqualToString:userID])
        {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

#pragma mark - Text Field Delegate - Name Changing


// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect openRect = self.view.frame;
    openRect.size.height -= kbSize.height;
    openRect.origin.y += self.scrollView.contentOffset.y;
    
    CGRect fieldRect = [self.activeField.superview convertRect:self.activeField.frame toView:self.scrollView];
    if (!CGRectContainsPoint(openRect, fieldRect.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, fieldRect.origin.y-kbSize.height + 20);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}


- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"Start");
    
    self.activeField = textField;
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"Return");
    self.activeField = nil;
    
    [self.mainViewController.manager changeMyName:textField.text];
    [textField endEditing:YES];
    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"End");
    return YES;
}

#pragma mark - Protobowl Leaderboard Delegate Methods
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateUsers:(NSArray *)users inRoom:(NSString *)roomName
{
    self.leaderboardTitle.text = [NSString stringWithFormat:@"Leaderboard - %@ (%d)", roomName, [self countActiveUsers:users]];
    self.users = users;
    
    [self reloadLeaderboard];
}

@end
