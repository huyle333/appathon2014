//
//  SimpleTableViewController.h
//  HackPrinceton
//
//  Created by Huy on 3/30/14.
//  Copyright (c) 2014 Huy Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimpleTableViewController;

@interface SimpleTableViewController : UITableViewController{
    UIWindow *window;
    IBOutlet UITabBarController *rootController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;

@end
