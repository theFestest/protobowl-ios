//
//  ChatViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 8/23/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProtobowlConnectionManager.h"
#import "JSMessagesViewController.h"

typedef void (^UpdateChatTextCallback)(NSString *chat);
typedef void (^SubmitChatCallback)(NSString *chat);
typedef void (^DoneChatCallback)();

@interface ChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate, ProtobowlChatDelegate>

@property (nonatomic, strong) UpdateChatTextCallback updateChatTextCallback;
@property (nonatomic, strong) SubmitChatCallback submitChatTextCallback;
@property (nonatomic, strong) DoneChatCallback doneChatCallback;

@end
