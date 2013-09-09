//
//  SideMenuViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/20/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "PublicRoomsViewController.h"
#import "UIView+Donald.h"
#import "UIColor+MoreConstructors.h"
#import "ProtobowlRoom.h"
#import <QuartzCore/QuartzCore.h>

#define kLeaderboardCellHeight 44
#define kLeaderboardDetailCellHeight 180

@interface PublicRoomsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *publicRoomsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *publicRoomsTableViewHeight;
@property (nonatomic, strong) NSArray *publicRooms;
@end

@implementation PublicRoomsViewController
@synthesize sideMenuViewController;


- (void) loadPublicRoomData
{
    NSLog(@"Fetching public rooms from server");
    
    [self.mainViewController.manager fetchPublicRoomDataWithCallback:^(NSArray *rooms) {
        self.publicRooms = rooms;
        NSLog(@"Fetched public rooms from server");
        
        [self reloadPublicRoomsTableView];
        [self.sideMenuViewController reloadTableView];
    }];
}

- (void) reloadPublicRoomsTableView
{
    [self.publicRoomsTableView reloadData];
    float targetHeight = [self calculateTableHeight];
    self.publicRoomsTableView.contentSize = CGSizeMake(self.publicRoomsTableView.contentSize.width, targetHeight);
    [self.publicRoomsTableView reloadData];
    [self resizeTableView];
}


- (void) resizeTableView
{
    NSLog(@"Resizing!");
    CGRect frame = self.publicRoomsTableView.frame;
    frame.size.height = self.publicRoomsTableView.contentSize.height;
    self.publicRoomsTableViewHeight.constant = self.publicRoomsTableView.contentSize.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.publicRoomsTableView.frame = frame;
    }];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self loadPublicRoomData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadPublicRoomData];
}


#pragma mark - Table View Delegate Methods
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.publicRooms)
    {
        return self.publicRooms.count;
    }
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicRoomCell" forIndexPath:indexPath];
    
    if(self.publicRooms)
    {
        ProtobowlRoom *room = self.publicRooms[indexPath.row];

        cell.textLabel.text = room.name;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d active", room.numberActive];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    }
    else
    {
        cell.textLabel.text = @"Could not connect to server";
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected");
    
    NSString *roomName = [self.publicRooms[indexPath.row] name];
    
    [self.mainViewController.manager connectToRoom:roomName];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}



- (float) expandedHeight
{
    return [self calculateTableHeight] + 43; // Magic numbers via experimentation.  This value leaves a nice double thick line at the bottom of the leaderboard.
}


- (float) calculateTableHeight
{
    int rows = [self.publicRoomsTableView.dataSource tableView:self.publicRoomsTableView numberOfRowsInSection:0];
    float height = 0;
    for(int i = 0; i < rows; i++)
    {
        height += [self.publicRoomsTableView.delegate tableView:self.publicRoomsTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    return height;
}

@end
