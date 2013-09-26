//
//  AppDelegate.m
//  Protobowl
//
//  Created by Donald Pinckney on 6/11/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "Appirater.h"

@interface AppDelegate ()
@property (nonatomic) BOOL justLaunched;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    
    [ProtobowlConnectionManager saveServerListToDisk];
    
    self.justLaunched = YES;
    
    [Appirater setAppId:@"716914125"];
//    [Appirater setDebug:YES];
    [Appirater appLaunched:YES];
    
    return YES;
}

- (void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    printf("hello\n");
    
}

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        MainViewController *mainVC = (MainViewController *)navigationController.topViewController;
        [mainVC.manager saveReconnectData];
    }
    else
    {
        MainViewController *mainVC = (MainViewController *)self.window.rootViewController;
        [mainVC.manager saveReconnectData];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        MainViewController *mainVC = (MainViewController *)navigationController.topViewController;
        [mainVC.manager connectToRoom:[url host]];
    }
    else
    {
        MainViewController *mainVC = (MainViewController *)self.window.rootViewController;
        [mainVC.manager connectToRoom:[url host]];
    }
    return YES;

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if(!self.justLaunched)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
            UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
            MainViewController *mainVC = (MainViewController *)navigationController.topViewController;
            [mainVC.manager reconnectIfNeeded];
        }
        else
        {
            MainViewController *mainVC = (MainViewController *)self.window.rootViewController;
            [mainVC.manager reconnectIfNeeded];
        }
    }
    self.justLaunched = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
