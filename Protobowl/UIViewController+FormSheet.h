//
//  UIViewController+FormSheet.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/31/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (FormSheet)

- (void) presentFormViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;
- (void) dismissFormViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;

@end
