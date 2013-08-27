//
//  ChatViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 8/23/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "ChatViewController.h"
#import "LinedTableViewController.h"

@interface ChatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *chatField;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

@property (nonatomic, strong) LinedTableViewController *chatController;
@end


#define kChatCellIdentifier @"ChatCell"
@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.chatField becomeFirstResponder];
    self.chatField.delegate = self;
    
    self.chatController = [[LinedTableViewController alloc] initWithCellIdentifier:kChatCellIdentifier inTableView:self.chatTableView];
    self.chatTableView.dataSource = self.chatController;
    self.chatTableView.delegate = self.chatController;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    self.submitChatTextCallback(textField.text);
    return YES;
}

- (IBAction)chatChanged:(id)sender
{
    self.updateChatTextCallback([sender text]);
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines
{
    [self.chatController setLineArray:lines];
}

@end
