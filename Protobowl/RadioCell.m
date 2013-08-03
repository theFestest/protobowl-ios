//
//  RadioCell.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/30/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "RadioCell.h"
#import "UIViewController+FormSheet.h"
#import "RadioGroupViewController.h"

@implementation RadioCell

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        RadioGroupViewController *form = [self.referenceViewController.storyboard instantiateViewControllerWithIdentifier:@"RadioGroupViewController"];
        form.options = self.options;
        form.selection = self.selection;
        form.radioChangedCallback = self.radioChangedCallback;
        __weak RadioGroupViewController *weakForm = form;
        form.radioDoneCallback = ^{
            [self.referenceViewController dismissFormViewController:weakForm animated:YES completion:nil];
        };
        form.title = self.titleLabel.text;
        [self.referenceViewController presentFormViewController:form animated:YES completion:nil];
        
        [self setSelected:NO animated:YES];
    }
}

@end
