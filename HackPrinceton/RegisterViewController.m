//
//  RegisterViewController.m
//  HackPrinceton
//
//  Created by Huy on 3/29/14.
//  Copyright (c) 2014 Huy Le. All rights reserved.
//

#import "RegisterViewController.h"
#import <Parse/Parse.h>

@implementation RegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void) viewDidAppear:(BOOL)animated{
    PFUser *user = [PFUser currentUser];
    if(user.username != nil){
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldReturn:(id)sender{
    [sender resignFirstResponder];
}

- (IBAction)registerAction:(id)sender{
    [_usernameField resignFirstResponder];
    [_emailField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_reenterPasswordField resignFirstResponder];
    [self checkFieldsComplete];
}

- (void) checkFieldsComplete{
    if([_usernameField.text isEqualToString: @""] || [_emailField.text isEqualToString: @""] || [_passwordField.text isEqualToString: @""] || [_reenterPasswordField.text isEqualToString: @""] ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"You need to complete all fields" delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alert show];
    }else{
        [self checkPasswordsMatch];
    }
}

- (void) checkPasswordsMatch{
    if(![_passwordField.text isEqualToString:_reenterPasswordField.text]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Passwords do not match" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alert show];
    }else{
        [self registerNewUser];
    }
}

- (void) registerNewUser{
    NSLog(@"Registering...");
    PFUser *newUser = [PFUser user];
    newUser.username = _usernameField.text;
    newUser.email = _emailField.text;
    newUser.password = _passwordField.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(!error){
            NSLog(@"Registration success!");
            [self performSegueWithIdentifier:@"login" sender:self];
        }else{
            NSLog(@"There was an error in registration");
        }
    }];
}


@end
