//
//  AppDelegate.m
//  SmartReminderApp
//
//  Created by Shana Azria Dev on 10/21/15.
//  Copyright © 2015 Shana Azria Dev. All rights reserved.
//

#import "AppDelegate.h"
#import "MyManager.h"
#define myManager [MyManager sharedManager]
#import <Parse/Parse.h>


@interface AppDelegate () <UIAlertViewDelegate>
@end

@implementation AppDelegate {
    bool firstTaskCompleted;
    NSDictionary *infoDict;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"pjc2KiLTZcnq0zFbhVdhQfQwvQsVhPn0kqXDvVuZ"
                  clientKey:@"lUk8KmC01wlfzgaFuMrxWeZYzh0a2mR4rTam6Kdr"];
    if([PFUser currentUser]) {
        // user authenticated
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        UINavigationController *navigation = (UINavigationController*)[mainStoryboard
                                                                       instantiateViewControllerWithIdentifier: @"mainNav"];
        UIViewController* homeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"homeVC"];
        [navigation pushViewController:homeVC animated:NO];
        self.window.rootViewController = navigation;
        [self.window makeKeyAndVisible];
        
    } else {
        // No user is signed in
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    NSLog(@"location received");
    // Handle actions of local notifications here. You can identify the action by using "identifier" and perform appropriate operations
    NSDictionary *info = notification.userInfo;
    NSLog(@"info received %@", info);
    if ([identifier isEqualToString:@"ACTION_ONE"]) {
        [myManager acceptNotif:info];
        [myManager sendStatusNotif:@"accepted" withInfo:info];
    } else if ([identifier isEqualToString:@"ACTION_TWO"]) {
        [myManager sendStatusNotif:@"denied" withInfo:info];
        NSLog(@"You chose action 2. The task was not completed");
    }

    if(completionHandler != nil)    //Finally call completion handler if its not nil
        completionHandler();
}

@end
