//
//  LoginViewController.h
//  SmartReminderApp
//
//  Created by Shana Azria Dev on 3/2/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)loginPressed:(id)sender;
- (IBAction)signupPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end
