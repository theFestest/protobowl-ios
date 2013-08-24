//
//  ChatViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 8/23/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *chatField;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.chatField becomeFirstResponder];
    self.chatField.delegate = self;
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

@end
