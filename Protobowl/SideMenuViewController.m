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
#import "SideMenuExpandedCell.h"
#import "LeaderboardViewController.h"
#import "SettingsViewController.h"
#import "PublicRoomsViewController.h"

#define kLeaderboardCellHeight 44
#define kLeaderboardDetailCellHeight 180

@interface SideMenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *users;

@property (nonatomic) int selectedRow;
@property (nonatomic, strong) SideMenuExpandedCell *selectedCell;
@property (nonatomic, strong) id<CellViewController> selectedCellController;

@property (weak, nonatomic) IBOutlet UITextField *roomNameField;

@property (nonatomic) BOOL isShareViewControllerPresented;

@end

@implementation SideMenuViewController

- (void) reloadTableView
{
    [self.tableView reloadData];
    float targetHeight = [self calculateTableHeight];
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, targetHeight);
    [self.tableView reloadData];
    [self resizeTableView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, targetHeight + 200);
}

- (void) reloadTableViewAtIndices:(NSArray *)indices numDetailRows:(int)n
{
    [self.tableView reloadRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationFade];
    float targetHeight = [self calculateTableHeight];
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, targetHeight);
    [self.tableView reloadRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationNone];
    [self resizeTableView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, targetHeight + 200);
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
    
    [self.tableView applyStandardSinkStyle];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    
    self.selectedRow = -1;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if(self.isShareViewControllerPresented)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        self.isShareViewControllerPresented = NO;
    }
}


- (void) setFullyOnscreen:(BOOL) onscreen
{
    if(onscreen)
    {
        [self.view.layer setShadowOpacity:0.0];
        [self.view.layer setShadowRadius:0.0];
        [self.view.layer setShadowColor:nil];
        
        [self reloadTableView];
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
    CGRect frame = self.tableView.frame;
    frame.size.height = self.tableView.contentSize.height;
    self.tableViewHeight.constant = self.tableView.contentSize.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = frame;
    }];
}

#pragma mark - Table View Delegate Methods
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.selectedRow)
    {
        SideMenuExpandedCell *cell = nil;
        if(self.selectedCell == nil)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuExpandedCell" forIndexPath:indexPath];
            cell.parentVC = self;
            UIViewController<CellViewController> *vc = nil;
            
            if(indexPath.row == 0)
            {
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LeaderboardViewController"];
                ((LeaderboardViewController *)vc).mainViewController = self.mainViewController;
                self.mainViewController.manager.leaderboardDelegate = (LeaderboardViewController *)vc;
            }
            else if(indexPath.row == 1)
            {
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
                [((SettingsViewController *)vc) setupWithPlistPath:plistPath];
                self.mainViewController.manager.settingsDelegate = (SettingsViewController *)vc;
            }
            else if(indexPath.row == 2)
            {
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PublicRoomsViewController"];
                ((PublicRoomsViewController *)vc).mainViewController = self.mainViewController;
            }
            else if(indexPath.row == 3)
            {
                vc = nil;
            }
            else
            {
                vc = nil;
            }
            
            vc.sideMenuViewController = self;
            [cell setViewController:vc];
            
            self.selectedCell = cell;
            self.selectedCellController = vc;
        }
        else
        {
            cell = self.selectedCell;
        }
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuCollapsedCell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
        
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"Leaderboard";
                break;
            case 1:
                cell.textLabel.text = @"Settings";
                break;
            case 2:
                cell.textLabel.text = @"Public Rooms";
                break;
            case 3:
                cell.textLabel.text = @"Question History";
                break;
            default:
                cell.textLabel.text = @"";
                break;
        }
        
        UIImageView *downArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_arrow"]];
        CGRect frame = downArrowView.frame;
        frame.size.width /= 2.0;
        frame.size.height /= 2.0;
        downArrowView.frame = frame;
        cell.accessoryView = downArrowView;
        
        return cell;
    }
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.selectedRow)
    {
        float height = [self.selectedCellController expandedHeight];
        printf("%g\n", height);
        return height;
    }
    return 44;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected");
    
    self.selectedCell = nil;
    self.selectedCellController = nil;
    int lastSelected = self.selectedRow;
    self.selectedRow = indexPath.row;
    if(lastSelected == indexPath.row)
    {
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
    else if(lastSelected != -1)
    {
        [self reloadTableViewAtIndices:@[[NSIndexPath indexPathForRow:lastSelected inSection:indexPath.section], indexPath] numDetailRows:1];
    }
    else
    {
        [self reloadTableViewAtIndices:@[indexPath] numDetailRows:1];
    }
}


- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Deselected");
    self.selectedRow = -1;
    self.selectedCell = nil;
    [self reloadTableViewAtIndices:@[indexPath] numDetailRows:0];
}


- (float) calculateTableHeight
{
    int rows = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0];
    float height = 0;
    for(int i = 0; i < rows; i++)
    {
        height += [self.tableView.delegate tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    return height;
}

- (void) setRoomName:(NSString *)room
{
    self.roomNameField.text = [NSString stringWithFormat:@"Room Name - %@", room];
}


- (IBAction)sharePressed:(id)sender
{
    NSString *shareURL = [NSString stringWithFormat:@"http://protobowl.com/%@", self.mainViewController.manager.currentRoomName];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareURL] applicationActivities:nil];
    activityVC.completionHandler = ^(NSString *activityType, BOOL completed) {
        self.isShareViewControllerPresented = NO;
    };
    [self presentViewController:activityVC animated:YES completion:nil];
    self.isShareViewControllerPresented = YES;
}



- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"Start");
    
    textField.text = self.mainViewController.manager.currentRoomName;
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"Return");
    
    [self.mainViewController.manager connectToRoom:textField.text];
    
    [textField endEditing:YES];
    
    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"End");
    return YES;
}


@end
