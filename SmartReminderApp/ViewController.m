//
//  ViewController.m
//  SmartReminderApp
//
//  Created by Shana Azria Dev on 10/21/15.
//  Copyright © 2015 Shana Azria Dev. All rights reserved.
//

#import "ViewController.h"
#import "EstimoteSDK/EstimoteSDK.h"
#import "MyManager.h"
#import <Parse/Parse.h>
#define myManager [MyManager sharedManager]

@interface ViewController () <ESTBeaconManagerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@end

@implementation ViewController
NSString * const NotificationCategoryIdent  = @"ACTIONABLE";
NSString * const NotificationActionOneIdent = @"ACTION_ONE";
NSString * const NotificationActionTwoIdent = @"ACTION_TWO";
NSMutableArray *roomSelection;
NSDictionary *infoDict;
NSMutableArray *tasksIDS;
bool didExit;


#pragma mark - View Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    roomSelection = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", nil];
    
    //text field setup
    self.titleTextField.delegate = self;
    self.step1Field.delegate = self;
    self.step2Label.delegate = self;
    self.step3Label.delegate = self;
    
    //button setup
    self.room1Btn.clipsToBounds = YES;
    self.room1Btn.layer.cornerRadius = 5;
    self.room2Btn.clipsToBounds = YES;
    self.room2Btn.layer.cornerRadius = 5;
    self.room3Btn.clipsToBounds = YES;
    self.room3Btn.layer.cornerRadius = 5;
    
    tasksIDS = [[NSMutableArray alloc] init];
    didExit = YES;
    
    [myManager setupRegion];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self registerForNotification];
    });
    
}

- (void) viewDidAppear:(BOOL)animated {
    self.titleTextField.text = @"";
    self.step1Field.text = @"";
    self.step2Label.text = @"";
    self.step3Label.text = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"monitoringFound"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) clearFields {
    self.step1Field.text = @"";
    self.step2Label.text = @"";
    self.step3Label.text = @"";
    self.titleTextField.text = @"";
    roomSelection[0] = @"";
    roomSelection[1] = @"";
    roomSelection[2] = @"";
    [self.room1Btn setTitle:@"select a room" forState:UIControlStateNormal];
    [self.room2Btn setTitle:@"select a room" forState:UIControlStateNormal];
    [self.room3Btn setTitle:@"select a room" forState:UIControlStateNormal];
    
}


#pragma mark - Beacon/Notif Setup

- (void) beaconSetup {
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    [self.beaconManager requestAlwaysAuthorization];
    
    CLBeaconRegion *region;
    for (int i = 0; i < [[myManager beaconsList] count]; i ++) {
        region= [[CLBeaconRegion alloc]
                 initWithProximityUUID:[[NSUUID alloc]
                                        initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
                 major:(CLBeaconMajorValue)[[myManager beaconsList][0][@"major"] intValue] minor:(CLBeaconMajorValue)[[myManager beaconsList][0][@"minor"] intValue] identifier:@"monitored region"];
        NSLog(@"monitoring region: %@", region);
        [self.beaconManager startMonitoringForRegion:region];
    }
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"monitoringFound"]) {
        NSLog(@"notif!");
        [self beaconSetup];
    }
}

- (void)registerForNotification {
    
    UIMutableUserNotificationAction *action1;
    action1 = [[UIMutableUserNotificationAction alloc] init];
    [action1 setActivationMode:UIUserNotificationActivationModeBackground];
    [action1 setTitle:@"Accept"];
    [action1 setIdentifier:NotificationActionOneIdent];
    [action1 setDestructive:NO];
    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action2;
    action2 = [[UIMutableUserNotificationAction alloc] init];
    [action2 setActivationMode:UIUserNotificationActivationModeBackground];
    [action2 setTitle:@"Not now"];
    [action2 setIdentifier:NotificationActionTwoIdent];
    [action2 setDestructive:NO];
    [action2 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *actionCategory;
    actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:NotificationCategoryIdent];
    [actionCategory setActions:@[action1, action2]
                    forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types
                                                 categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}



#pragma mark - Keyboard methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.titleTextField resignFirstResponder];
    [self.step1Field resignFirstResponder];
    [self.step2Label resignFirstResponder];
    [self.step3Label resignFirstResponder];
}


#pragma mark - Beacon Delegate

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons
             inRegion:(CLBeaconRegion *)region {
    NSString *majorminor = [NSString stringWithFormat:@"%@%@", region.major, region.minor];
    if ([myManager myBeacons][majorminor]) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        if (nearestBeacon) {
            NSLog(@"%@", nearestBeacon);
        }
    }
    
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"did fail monitoring region!");
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Monitoring error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region
{
    NSLog(@"ENTERED");
    if (didExit) {
        NSLog(@"entered my region %@", region);
        didExit = NO;
        NSString *majorminor = [NSString stringWithFormat:@"%@%@", region.major, region.minor];
        [self checkHandleBeaconMovement:YES withMajorMinor:majorminor];
    }
    didExit = NO;
}


- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region
{
    NSLog(@"EXIT");
    if (!didExit) {
        NSLog(@"exited region %@ region", region);
        didExit = YES;
        NSString *majorminor = [NSString stringWithFormat:@"%@%@", region.major, region.minor];
        [self checkHandleBeaconMovement:NO withMajorMinor:majorminor];
    }
    didExit = YES;
}

- (void) checkHandleBeaconMovement:(bool)isEntry withMajorMinor:(NSString *)majorminor {
    NSLog(@"given majorminor %@", majorminor);
    NSInteger randomNumber = arc4random() % 10;
    if ([myManager myBeacons][majorminor]) {//the beacons around me are mine
        NSLog(@"entered my region beacon %ld so %ld", (long)randomNumber, randomNumber %2);
        [ViewController shouldLogNotifWithBlock:^(bool shouldLog, NSError *error) {
            [ViewController fetchBoolWithBlock:^(bool shouldSend, NSError *error) {
                if (shouldLog || shouldSend) {
                    [self logPotentialNotif:majorminor withStatus:@"entered"];
                }
                if ((randomNumber % 2) && shouldSend) {
                    [self sendNotif:majorminor];
                }
                
            }];
        }];
        
        
    }
}



#pragma mark - Log data to Parse


- (void)logMovement:(NSString *)status withMajorMinor:(NSString *)majorminor inRoom:(NSString *)room {
    PFObject *bObj = [PFObject objectWithClassName:@"Movement"];
    bObj[@"user"] = [PFUser currentUser].username;
    bObj[@"majorminor"] = majorminor;
    bObj[@"room"] = room;
    [bObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //succeeded
        } else {
            NSLog(@"Error");
            
        }
    }];

}

- (void) logNotif:(PFObject *)pObj withStatus:(NSString *)status{
    NSDictionary *info = (NSDictionary *)pObj;
    PFObject *bObj = [PFObject objectWithClassName:@"Notifications"];
    bObj[@"user"] = [PFUser currentUser].username;
    bObj[@"status"] = status;
    bObj[@"majorminor"] = info[@"majorminor"];
    bObj[@"taskID"] = info[@"taskID"];
    bObj[@"objectID"] = pObj.objectId;
    [bObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //succeeded
        } else {
            NSLog(@"Error");
            
        }
    }];
}

- (void) logPotentialNotif:(NSString *)majorminor withStatus:(NSString *)status{
    PFObject *bObj = [PFObject objectWithClassName:@"Notifications"];
    bObj[@"user"] = [PFUser currentUser].username;
    bObj[@"status"] = status;
    bObj[@"majorminor"] = majorminor;
    bObj[@"taskID"] = @"-1";
    bObj[@"objectID"] = @"-1";
    [bObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //succeeded
        } else {
            NSLog(@"Error");
            
        }
    }];
}

- (void) sendNotif:(NSString *)majorminor {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Beacons"];
    [query whereKey:@"majorminor" equalTo:majorminor];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query whereKey:@"completed" equalTo:@NO];
    [query whereKey:@"prevCompleted" equalTo:@YES];
    [query orderByAscending:@"createdAt"];
    NSLog(@"majorminor is %@", majorminor);
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"obbjects found in send notif %@", objects);
            // The find succeeded.
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
            // Do something with the found objects
            if (objects) {
                PFObject *pObj = [objects objectAtIndex:0];
                NSDictionary *obj = [objects objectAtIndex:0];
                NSString *body = [NSString  stringWithFormat:@"%@: %@ in the %@.", obj[@"maintask"], obj[@"microtask"], obj[@"room"]];
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                NSDictionary *info = @{
                                       @"objID":pObj.objectId,
                                       @"taskID":obj[@"taskID"],
                                       @"index":obj[@"index"],
                                       @"majorminor":majorminor,
                                       @"nextID": obj[@"nextID"],
                                       @"maintask":obj[@"maintask"],
                                       @"microtask":obj[@"microtask"]
                                       };
                notification.userInfo = info;
                notification.alertBody = body;
                notification.category = NotificationCategoryIdent;
                [self logNotif:pObj withStatus:@"sent"];
                if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
                    // show an alert view
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:body
                                                                        message:@""
                                                                       delegate:self
                                                              cancelButtonTitle:@"Not now"
                                                              otherButtonTitles:@"Accept", nil];
                    infoDict = info;
                    alertView.tag = 5;
                    [alertView show];
                }
                else {
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                    // your local notification configuration
                }
                
                
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}



#pragma mark - Fetch Parse timers


+ (void)fetchBoolWithBlock:(void (^)(bool , NSError *))block {
    NSLog(@"made it to fetch");
    __block bool returnVal = YES;
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    [query whereKey:@"status" equalTo:@"sent"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"objects %@ error %@", objects, error);
        if ([objects count] > 0) {
            PFObject *obj = [objects objectAtIndex:0];
            NSDate *d = obj.createdAt;
            NSDate* currentDate = [NSDate date];
            NSLog(@"time difference is %f", [currentDate timeIntervalSinceDate:d]/60);
            if ([currentDate timeIntervalSinceDate:d]/60 < 25) {
                NSLog(@"not enough time diff, should not send notif");
                returnVal = NO;
            } else {
                 NSLog(@"enough time diff, should send notif");
            }
        } else {
             NSLog(@"enough time diff, should send notif");
        }
        block(returnVal, nil);
    }];
}

+ (void)shouldLogNotifWithBlock:(void (^)(bool , NSError *))block {
    NSLog(@"made it to fetch bool notif");
    __block bool returnVal = YES;
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"objects %@ error %@", objects, error);
        if ([objects count] > 0) {
            PFObject *obj = [objects objectAtIndex:0];
            NSDate *d = obj.createdAt;
            NSDate* currentDate = [NSDate date];
            NSLog(@"time difference is %f", [currentDate timeIntervalSinceDate:d]/60);
            if ([currentDate timeIntervalSinceDate:d]/60 < 5) {
                NSLog(@"not enough time diff, should not log notif");
                returnVal = NO;
            } else {
                NSLog(@"enough time diff, should log notif");
            }
        } else {
            NSLog(@"enough time diff, should log notif");
        }
        block(returnVal, nil);
    }];
}

#pragma mark - Alert view/Action sheet

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 5) {
        NSLog(@"received alert notif");
        if (buttonIndex != [alertView cancelButtonIndex]) {
            [myManager acceptNotif:infoDict];
            [myManager sendStatusNotif:@"accepted" withInfo:infoDict];
        } else {
            [myManager sendStatusNotif:@"denied" withInfo:infoDict];
            NSLog(@"You chose action 2. The task was not completed");
        }
        infoDict = [[NSDictionary alloc] init];
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        roomSelection[actionSheet.tag] = [actionSheet buttonTitleAtIndex:buttonIndex];
        if (actionSheet.tag == 0) {
            [self.room1Btn setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        } else if (actionSheet.tag == 1) {
            [self.room2Btn setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        } else if (actionSheet.tag == 2) {
            [self.room3Btn setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        }
    }
    
    
}


#pragma mark - Check input

- (BOOL)checkRoomFilledOut {
    if (![self.step3Label.text isEqualToString:@""] && ([self.step2Label.text isEqualToString:@""] || [self.step1Field.text isEqualToString:@""])) {
        return false;
    }
    if (![self.step2Label.text isEqualToString:@""] && [[roomSelection objectAtIndex:1] isEqualToString:@""]) {
        return false;
    } else if (![self.step3Label.text isEqualToString:@""] && [[roomSelection objectAtIndex:2] isEqualToString:@""]) {
        return false;
    }
    return true;
}

- (int)getStepsNum {
    int count  = 0;
    if (![self.step1Field.text isEqualToString:@""]) count ++;
    if (![self.step2Label.text isEqualToString:@""]) count ++;
    if (![self.step3Label.text isEqualToString:@""]) count ++;
    return count;
}

#pragma mark - Save new task

- (void)saveMicrotasks:(NSMutableArray*)tasks withMainTask:(NSString *)mainTask withObjID:(NSString *)objID withIndex:(NSNumber *)index {
    PFObject *bObj = [PFObject objectWithClassName:@"Beacons"];
    bObj[@"user"] = [PFUser currentUser].username;
    bObj[@"completed"] = @NO;
    bObj[@"prevCompleted"] = @NO;
    bObj[@"nextID"] = @"";
    bObj[@"index"] = index;
    bObj[@"maintask"] = mainTask;
    bObj[@"taskID"] = objID;
    bObj[@"microtask"] = [tasks objectAtIndex:(NSUInteger)index.intValue][@"task"];
    bObj[@"majorminor"] = [tasks objectAtIndex:(NSUInteger)index.intValue][@"majorminor"];
    bObj[@"room"] = [tasks objectAtIndex:(NSUInteger)index.intValue][@"room"];
    if (index.intValue == 0) {
        bObj[@"prevCompleted"] = @YES;
    }
    [bObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [tasksIDS addObject:bObj.objectId];
            if ((NSUInteger)index.intValue < [tasks count]-1) {
                [self saveMicrotasks:tasks withMainTask:mainTask withObjID:objID withIndex:[NSNumber numberWithInt:(index.intValue + 1)]];
            } else {
                [self updateNextIDS];
            }
            
        } else {
            NSLog(@"Error");
          
        }
    }];
    
}

- (void) updateNextIDS {
    for (int i = 0; i < [tasksIDS count]-1; i++) {
        PFQuery *query = [PFQuery queryWithClassName:@"Beacons"];
        // Retrieve the object by id
        [query getObjectInBackgroundWithId:[tasksIDS objectAtIndex:i]
                                     block:^(PFObject *task, NSError *error) {
                                         // Now let's update it with some new data. In this case, only cheatMode and score
                                         // will get sent to the cloud. playerName hasn't changed.
                                         task[@"nextID"] = [tasksIDS objectAtIndex:i+1];
                                         [task saveInBackground];
                                         if (i == [tasksIDS count]-1) {
                                             tasksIDS = [[NSMutableArray alloc] init];

                                         }
                                     }];
    }
}

- (IBAction)submitReminder:(UIButton *)sender {
    bool roomsSelected = [self checkRoomFilledOut];
    if ([self.titleTextField.text isEqualToString:@""] || [self.step1Field.text isEqualToString:@""] || [[roomSelection objectAtIndex:0] isEqualToString:@""]) {
        UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Reminder list imcomplete."
                                                            message:@"You must fill out the first step"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [errorView show];
    } else if (![self.titleTextField.text isEqualToString:@""] && roomsSelected) {
        NSMutableArray *tasks = [[NSMutableArray alloc] init];
        
        if (![self.step1Field.text isEqualToString:@""]) {
            NSDictionary *dict = @{
                                   @"room":[roomSelection objectAtIndex:0],
                                   @"task":self.step1Field.text,
                                   @"majorminor":[myManager beaconIDs][[roomSelection objectAtIndex:0]]
                                   };
            [tasks addObject:dict];
        }
        if (![self.step2Label.text isEqualToString:@""]) {
            NSDictionary *dict = @{
                                   @"room":[roomSelection objectAtIndex:1],
                                   @"task":self.step2Label.text,
                                   @"majorminor":[myManager beaconIDs][[roomSelection objectAtIndex:1]]
                                   };
            [tasks addObject:dict];
        }
        if (![self.step3Label.text isEqualToString:@""]) {
            NSDictionary *dict = @{
                                   @"room":[roomSelection objectAtIndex:2],
                                   @"task":self.step3Label.text,
                                   @"majorminor":[myManager beaconIDs][[roomSelection objectAtIndex:2]]
                                   };
            [tasks addObject:dict];
        }
        
        //save task
        PFObject *bObj = [PFObject objectWithClassName:@"Tasks"];
        bObj[@"user"] = [PFUser currentUser].username;
        bObj[@"allCompleted"] = @NO;
        bObj[@"numCompleted"] = [NSNumber numberWithInt:0];
        bObj[@"microtasks"] = tasks;
        bObj[@"maintask"] = self.titleTextField.text;
        [bObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSString *alertTitle = @"";
            NSString *alertDetail = @"";
            if (succeeded) {
                alertTitle = @"Sucess";
                alertDetail = @"You added a new task";
                [self saveMicrotasks:tasks withMainTask:self.titleTextField.text withObjID:bObj.objectId withIndex:[NSNumber numberWithInt:0]];
                UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                    message:alertDetail
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [errorView show];
                [self clearFields];
                //[self updateNextIDS];
            } else {
                NSLog(@"Error");
                // There was a problem, check error.description
                alertTitle = @"Error";
                alertDetail = @"Could not add task, try again";
                UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                    message:alertDetail
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [self clearFields];
                [errorView show];
            }
            
            
            
            
        }];
        
    } else {
        UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Reminder list imcomplete."
                                                            message:@"You must fill out matching microtasks and locations"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [errorView show];
    }

}


#pragma mark - Room selection (action sheet)

- (IBAction)selectRoom1:(id)sender {
    [self.view endEditing:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick a room:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[myManager roomInfo][@"beacon2Room"], [myManager roomInfo][@"beacon1Room"], nil];
    actionSheet.tag = 0;
    
    [actionSheet showInView:self.view];
}

- (IBAction)selectRoom2:(id)sender {
    [self.view endEditing:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick a room:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[myManager roomInfo][@"beacon2Room"], [myManager roomInfo][@"beacon1Room"], nil];
    actionSheet.tag = 1;
    
    [actionSheet showInView:self.view];
}

- (IBAction)selectRoom3:(id)sender {
    [self.view endEditing:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick a room:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[myManager roomInfo][@"beacon2Room"], [myManager roomInfo][@"beacon1Room"], nil];
    actionSheet.tag = 2;
    
    [actionSheet showInView:self.view];
    
}

#pragma mark - Logout

- (IBAction)logoutPressed:(id)sender {
    if ([[myManager beaconsList] count] > 0) {
            CLBeaconRegion *region= [[CLBeaconRegion alloc]
                                     initWithProximityUUID:[[NSUUID alloc]
                                                            initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
                                     major:(CLBeaconMajorValue)[[myManager beaconsList][1][@"major"] intValue] minor:(CLBeaconMajorValue)[[myManager beaconsList][1][@"minor"] intValue] identifier:@"monitored region"];
            NSLog(@"monitoring region: %@", region);
            [self.beaconManager stopMonitoringForRegion:region];
            // [self.beaconManager startRangingBeaconsInRegion:region];
    }
    didExit = YES;
    [myManager clearAllMemory];
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
