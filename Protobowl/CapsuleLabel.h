//
//  CapsuleLabel.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/23/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

enum StatusColor {
    StatusColorOnline = 0,
    StatusColorOffline = 1,
    StatusColorSelf = 2,
    StatusColorIdle = 3
};
typedef enum StatusColor StatusColor;

@interface CapsuleLabel : UILabel

- (void) setStatusColor:(StatusColor)color;

@end
