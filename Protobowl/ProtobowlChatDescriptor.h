//
//  ProtobowlChatDescriptor.h
//  Protobowl
//
//  Created by Donald Pinckney on 8/27/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProtobowlChatDescriptor : NSObject
@property (nonatomic, strong) NSString *chatText; // Does NOT include player's name
@property (nonatomic, strong) NSString *playerName;
@property (nonatomic, strong) NSDate *chatDate;
@property (nonatomic) BOOL isMe;
@end
