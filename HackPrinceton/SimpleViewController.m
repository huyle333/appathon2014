//
//  SimpleViewController.m
//  HackPrinceton
//
//  Created by Huy on 3/29/14.
//  Copyright (c) 2014 Huy Le. All rights reserved.
//

#import "SimpleViewController.h"
#import "Parse/Parse.h"
#import "MyTableController.h"

@interface SimpleViewController ()

@end

@implementation SimpleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    // Custom initialization
    MyTableController *controller = [[MyTableController alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.view.window makeKeyAndVisible];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
