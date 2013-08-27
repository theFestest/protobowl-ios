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
@property (nonatomic, strong) NSArray *chatLines;
@end


#define kChatCellIdentifier @"ChatCell"
@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    self.title = @"Chat";
    
    self.inputToolBarView.textView.returnKeyType = UIReturnKeySend;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
}

#pragma mark - JSMessagesViewDelegate Implementation
BOOL madeFinalCorrection = NO;
NSString *correctText;
BOOL completedMessage = NO;
- (void) sendPressed:(UIButton *)sender withText:(NSString *)text
{
    madeFinalCorrection = NO;
    [self finishSend];
    
    if(madeFinalCorrection)
    {
        text = correctText;
    }
    self.submitChatTextCallback(text);
    madeFinalCorrection = NO;
    completedMessage = YES;
    self.chatLines = [self.chatLines arrayByAddingObject:text];
    [self.tableView reloadData];
}

- (void) textViewDidChange:(UITextView *)textView
{
    [super textViewDidChange:textView];
    
    if(textView.text.length > 0)
    {
        madeFinalCorrection = YES;
        correctText = textView.text;
        self.updateChatTextCallback(textView.text);
        completedMessage = NO;
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        [self sendPressed:nil withText:textView.text];
        return NO;
    }
    
    return YES;
}

- (JSBubbleMessageType) messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageTypeIncoming; // Configure incoming / outgoing from received data from manager
}

- (JSBubbleMessageStyle) messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleSquare;
}

- (JSMessagesViewTimestampPolicy) timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy) avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

- (JSAvatarStyle) avatarStyle
{
    return JSAvatarStyleNone;
}



#pragma mark - JSMessagesViewDataSource Implementation
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.chatLines[indexPath.row];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NSDate date];
}

- (UIImage *) avatarImageForIncomingMessage
{
    return nil;
}

- (UIImage *) avatarImageForOutgoingMessage
{
    return nil;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatLines.count;
}



- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines
{
    self.chatLines = [lines copy];
    [self.tableView reloadData];
}

- (void) donePressed:(id)sender
{
    [self.inputToolBarView.textView resignFirstResponder];
    [self sendPressed:nil withText:self.inputToolBarView.textView.text];
    self.doneChatCallback();
}

@end
