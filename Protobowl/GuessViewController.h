//
//  GuessViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 6/14/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProtobowlConnectionManager.h"

@interface GuessViewController : UIViewController

@property (nonatomic, strong) NSString *questionDisplayText;
@property (nonatomic, weak) ProtobowlConnectionManager *manager;

@end
