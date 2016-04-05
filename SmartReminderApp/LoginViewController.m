//
//  LoginViewController.m
//  SmartReminderApp
//
//  Created by Shana Azria Dev on 3/2/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "LoginViewController.h"
#import "EstimoteSDK/EstimoteSDK.h"
#import "MyManager.h"
#import <Parse/Parse.h>
#define myManager [MyManager sharedManager]

@interface LoginViewController () <UITextFieldDelegate, ESTBeaconManagerDelegate>
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //set up text fields
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    [self.beaconManager requestAlwaysAuthorization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)navigateToMainVC {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"homeVC"];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void) clearTextFields {
    self.emailTextField.text = @"";
    self.passwordTextField.text = @"";
}

-(void)resignKeyboards {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignKeyboards];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.emailTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

-(void) fadeErrorMessage {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.errorLabel.alpha = 0;
                             
                         }
                         completion:^(BOOL finished) {
                             self.errorLabel.text = @"";
                             self.errorLabel.alpha = 1;
                         }];
        
    });
}

- (IBAction)loginPressed:(id)sender {
    if ([self.emailTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
        self.errorLabel.text = @"Cannot have blank fields";
        [self fadeErrorMessage];
    } else {
        [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                self.errorLabel.text = @"Login Successful";
                                                [self navigateToMainVC];
                                                // Do stuff after successful login.
                                            } else {
                                                NSLog(@"Error - %@", error);
                                                self.errorLabel.text = @"Error siging up in.";
                                                // The login failed. Check error to see why.
                                            }
                                            [self clearTextFields];
                                            [self fadeErrorMessage];
                                        }];

    }
    
}

- (IBAction)signupPressed:(id)sender {
    if ([self.emailTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
        self.errorLabel.text = @"Cannot have blank fields";
        [self fadeErrorMessage];
    } else {
        PFUser *user = [PFUser user];
        user.username = self.emailTextField.text;
        user.password = self.passwordTextField.text;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {   // Hooray! Let them use the app now.
                self.errorLabel.text = @"Signup Successful";
                [self navigateToMainVC];
                
            } else {
                NSLog(@"Error - %@", error);
                self.errorLabel.text = @"Error siging up in.";
                
            }
            [self clearTextFields];
            [self fadeErrorMessage];
        }];
    }
    
    
}
@end
