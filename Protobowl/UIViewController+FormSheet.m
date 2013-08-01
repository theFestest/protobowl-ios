//
//  UIViewController+FormSheet.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/31/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "UIViewController+FormSheet.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController (FormSheet)

#define kWidthInset 40
#define kHeightInset 80
#define kOverlayViewKey @"OverlayViewKey"
- (void) presentFormViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion
{
    CGRect frame = self.view.window.frame;
    frame.size.width -= kWidthInset * 2;
    frame.origin.x += kWidthInset;
    frame.size.height -= kHeightInset * 2;
    frame.origin.y += 80;
    
    self.view.clipsToBounds = NO;
    
    frame = [self.view convertRect:frame fromView:self.view.window];
    
    CGRect offscreen = frame;
    offscreen.origin.y = 600;
    
    CGRect fullscreen = self.view.window.frame;
    fullscreen = [self.view convertRect:fullscreen fromView:self.view.window];
    
    UIView *formOverlayView = [[UIView alloc] initWithFrame:fullscreen];
    formOverlayView.opaque = NO;
    formOverlayView.backgroundColor = [UIColor lightGrayColor];
    formOverlayView.alpha = 0.0;
    [self.view addSubview:formOverlayView];
    
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    
    vc.view.frame = offscreen;
    
    [vc.view.layer setCornerRadius:6.0];
    [vc.view.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [vc.view.layer setBorderWidth:1.0];
    vc.view.clipsToBounds = YES;
    
    objc_setAssociatedObject(self, kOverlayViewKey, formOverlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        vc.view.frame = frame;
        formOverlayView.alpha = 0.4;
        
    } completion:^(BOOL finished) {
        if(completion)
        {
            completion();
        }
    }];
}

- (void) dismissFormViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion
{
    CGRect frame = self.view.window.frame;
    frame.size.width -= kWidthInset * 2;
    frame.origin.x += kWidthInset;
    frame.size.height -= kHeightInset * 2;
    frame.origin.y += 80;
    
    self.view.clipsToBounds = NO;
    vc.view.clipsToBounds = NO;
    
    
    frame = [self.view convertRect:frame fromView:self.view.window];
    
    CGRect offscreen = frame;
    offscreen.origin.y = 600;
    
    CGRect fullscreen = self.view.window.frame;
    fullscreen = [self.view convertRect:fullscreen fromView:self.view.window];
    
    UIView *formOverlayView = objc_getAssociatedObject(self, kOverlayViewKey);
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        vc.view.frame = offscreen;
        formOverlayView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        if(completion)
        {
            [vc removeFromParentViewController];
            [vc.view removeFromSuperview];
            [formOverlayView removeFromSuperview];
            objc_setAssociatedObject(self, kOverlayViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            completion();
        }
    }];
}

@end
