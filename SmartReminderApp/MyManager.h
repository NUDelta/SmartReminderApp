//
//  MyManager.h
//  SmartReminderApp
//
//  Created by Shana Azria Dev on 10/21/15.
//  Copyright © 2015 Shana Azria Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyManager : NSObject {
  
    NSDictionary *beaconIDs;
    NSDictionary *myBeacons;
    NSArray *tasksArray;
    NSArray *beaconsList;
    NSDictionary *roomInfo;

}

@property (strong, nonatomic) NSArray *tasksArray;
@property (strong, nonatomic) NSDictionary *beaconIDs;
@property (strong, nonatomic) NSDictionary *myBeacons;
@property (strong, nonatomic) NSArray *beaconsList;
@property (strong, nonatomic) NSDictionary *roomInfo;

-(void) sendStatusNotif:(NSString *)status withInfo:(NSDictionary *)info;
-(void) acceptNotif:(NSDictionary *)info;
- (void)clearAllMemory;
- (void)setupRegion;

+ (id)sharedManager;

@end
