//
//  MyManager.m
//  SmartReminderApp
//
//  Created by Shana Azria Dev on 10/21/15.
//  Copyright © 2015 Shana Azria Dev. All rights reserved.
//

#import "MyManager.h"
#import <Parse/Parse.h>
#import "ViewController.h"

@implementation MyManager

@synthesize beaconIDs;
@synthesize myBeacons;
@synthesize tasksArray;
@synthesize beaconsList;
@synthesize roomInfo;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static MyManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


- (id)init {
    if (self = [super init]) {
        tasksArray = [[NSArray alloc] init];
    }
    return self;
}

- (void)setupRegion {
    PFQuery *query = [PFQuery queryWithClassName:@"BeaconIDs"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSDictionary *info = [objects objectAtIndex:0];
        NSLog(@"info beacon receive %@", info);
        if ([objects objectAtIndex:0]) {
            NSDictionary *beacons1 = @{
                                       @"major":info[@"beacon1Major"],
                                       @"minor":info[@"beacon1Minor"]
                                       };
            NSString *majorminor1 = [NSString stringWithFormat:@"%@%@", beacons1[@"major"], beacons1[@"minor"]];
            NSDictionary *beacons2 = @{
                                       @"major":info[@"beacon2Major"],
                                       @"minor":info[@"beacon2Minor"]
                                       };
            NSString *majorminor2 = [NSString stringWithFormat:@"%@%@", beacons2[@"major"], beacons2[@"minor"]];
            beaconsList = [[NSArray alloc] initWithObjects:beacons1, beacons2, nil];
            beaconIDs = @{
                          info[@"beacon2Room"]:majorminor2,
                          info[@"beacon1Room"]:majorminor1
                          };
            myBeacons = @{
                          majorminor2:info[@"beacon2Room"],
                          majorminor1:info[@"beacon1Room"]
                          };
            roomInfo = info;
            [[NSNotificationCenter defaultCenter] postNotificationName: @"monitoringFound" object:nil];
        }
        
    }];
}

- (void) clearAllMemory {
    tasksArray = [[NSArray alloc] init];
    beaconsList = [[NSArray alloc] init];
    beaconIDs = [[NSDictionary alloc] init];
    myBeacons = [[NSDictionary alloc] init];
    roomInfo = [[NSDictionary alloc] init];
    
}

-(void) sendStatusNotif:(NSString *)status withInfo:(NSDictionary *)info {
    PFObject *bObj = [PFObject objectWithClassName:@"Notifications"];
    bObj[@"user"] = [PFUser currentUser].username;
    bObj[@"status"] = status;
    bObj[@"majorminor"] = info[@"majorminor"];
    bObj[@"taskID"] = info[@"taskID"];
    bObj[@"objectID"] = info[@"objID"];
    [bObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //succeeded
        } else {
            NSLog(@"Error");
            
        }
    }];
}

-(void) acceptNotif:(NSDictionary *)info {
    PFQuery *query = [PFQuery queryWithClassName:@"Beacons"];
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:info[@"objID"]
                                 block:^(PFObject *task, NSError *error) {
                                     // Now let's update it with some new data. In this case, only cheatMode and score
                                     // will get sent to the cloud. playerName hasn't changed.
                                     if (task) {
                                         task[@"completed"] = @YES;
                                         [task saveInBackground];
                                     }
                                     
                                 }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"Beacons"];
    [query2 getObjectInBackgroundWithId:info[@"nextID"]
                                  block:^(PFObject *task, NSError *error) {
                                      // Now let's update it with some new data. In this case, only cheatMode and score
                                      // will get sent to the cloud. playerName hasn't changed.
                                      if (task) {
                                          task[@"prevCompleted"] = @YES;
                                          [task saveInBackground];
                                      }
                                      
                                  }];
    PFQuery *query3 = [PFQuery queryWithClassName:@"Tasks"];
    // Retrieve the object by id
    [query3 getObjectInBackgroundWithId:info[@"taskID"]
                                  block:^(PFObject *task, NSError *error) {
                                      // Now let's update it with some new data. In this case, only cheatMode and score
                                      // will get sent to the cloud. playerName hasn't changed.
                                      if (task) {
                                          int numCompleted = ((NSNumber*)task[@"numCompleted"]).intValue;
                                          numCompleted ++;
                                          if (numCompleted == [(NSArray *)task[@"microtasks"] count]) {
                                              task[@"allCompleted"] = @YES;
                                          }
                                          task[@"numCompleted"] = [NSNumber numberWithInt:numCompleted];
                                          [task saveInBackground];
                                      }
                                      
                                  }];
}


@end
