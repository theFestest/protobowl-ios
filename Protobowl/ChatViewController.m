//
//  ChatViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 8/23/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "ChatViewController.h"
#import "LinedTableViewController.h"
#import "ProtobowlChatDescriptor.h"

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
    if(self.title && ![self.title isEqualToString:@""]) // Workaround for setting title when view controller is not loaded yet
    {
        self.title = self.title;
    }
    else
    {
        self.title = @"Chat";
    }
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.inputToolBarView.textView.returnKeyType = UIReturnKeySend;
    self.inputToolBarView.textView.enablesReturnKeyAutomatically = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    
    [self.inputToolBarView.textView becomeFirstResponder];
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
    [self.tableView reloadData];
}

- (void) textViewDidChange:(UITextView *)textView
{
    [super textViewDidChange:textView];
    
    if(textView.text.length > 0)
    {
        madeFinalCorrection = YES;
        correctText = textView.text;
        self.updateChatTextCallback(textView.text, NO);
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
    return [self.chatLines[indexPath.row] isMe] ? JSBubbleMessageTypeOutgoing : JSBubbleMessageTypeIncoming;
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
    ProtobowlChatDescriptor *chat = self.chatLines[indexPath.row];
    if(chat.isMe)
    {
        if([chat.chatText isEqualToString:@""])
        {
            return @" ";
        }
        else
        {
            return chat.chatText;
        }
    }
    else
    {
        return [NSString stringWithFormat:@"%@: %@", chat.playerName, chat.chatText];
    }
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.chatLines[indexPath.row] chatDate];
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



- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines inRoom:(NSString *)roomName
{
    if(roomName)
    {
        self.title = [@"Chat - " stringByAppendingString:roomName];
    }
    else
    {
        self.title = @"Chat";
    }
    self.chatLines = [lines copy];
    [self.tableView reloadData];
}

- (void) donePressed:(id)sender
{
    [self.inputToolBarView.textView resignFirstResponder];
    if(self.inputToolBarView.textView.text.length > 0)
    {
        [self sendPressed:nil withText:self.inputToolBarView.textView.text];
    }
    self.doneChatCallback();

}

@end
