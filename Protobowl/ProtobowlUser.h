//
//  ProtobowlUser.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/21/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ProtobowlUserStatus {
    ProtobowlUserStatusOffline = 0,
    ProtobowlUserStatusOnline = 1,
    ProtobowlUserStatusSelf = 2,
    ProtobowlUserStatusIdle = 3
};
typedef enum ProtobowlUserStatus ProtobowlUserStatus;

@interface ProtobowlUser : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic) int score;
@property (nonatomic) int rank;
@property (nonatomic) int negs;
@property (nonatomic) ProtobowlUserStatus status;

@end
