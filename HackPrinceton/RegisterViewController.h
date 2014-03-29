//
//  RegisterViewController.h
//  HackPrinceton
//
//  Created by Huy on 3/29/14.
//  Copyright (c) 2014 Huy Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface RegisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reenterPasswordField;
- (IBAction)registerAction:(id)sender;
- (IBAction)textFieldReturn:(id)sender;



@end
