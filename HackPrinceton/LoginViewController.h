//
//  LoginViewController.h
//  HackPrinceton
//
//  Created by Huy on 3/29/14.
//  Copyright (c) 2014 Huy Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *loginUsernameField;
@property (weak, nonatomic) IBOutlet UITextField *loginPasswordField;
- (IBAction)loginAction:(id)sender;
- (IBAction)textFieldReturn:(id)sender;

@end
