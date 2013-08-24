//
//  ChatViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 8/23/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateChatTextCallback)(NSString *chat);
typedef void (^SubmitChatCallback)(NSString *chat);

@interface ChatViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UpdateChatTextCallback updateChatTextCallback;
@property (nonatomic, strong) SubmitChatCallback submitChatTextCallback;

@end
