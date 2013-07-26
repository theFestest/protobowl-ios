//
//  ViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 6/5/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProtobowlConnectionManager.h"

@interface MainViewController : UIViewController <ProtobowlRoomDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) ProtobowlConnectionManager *manager;
@end
