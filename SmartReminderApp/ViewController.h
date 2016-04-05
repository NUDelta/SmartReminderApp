//
//  ViewController.h
//  SmartReminderApp
//
//  Created by Shana Azria Dev on 10/21/15.
//  Copyright © 2015 Shana Azria Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
//@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
- (IBAction)submitReminder:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *step1Field;
@property (weak, nonatomic) IBOutlet UITextField *step2Label;
@property (weak, nonatomic) IBOutlet UITextField *step3Label;
@property (weak, nonatomic) IBOutlet UISwitch *orderedSwitch;
- (IBAction)selectRoom1:(id)sender;
- (IBAction)selectRoom2:(id)sender;
- (IBAction)selectRoom3:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *room1Btn;
@property (weak, nonatomic) IBOutlet UIButton *room2Btn;
@property (weak, nonatomic) IBOutlet UIButton *room3Btn;
- (IBAction)logoutPressed:(id)sender;

@end

