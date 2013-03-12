//
//  LoginViewController.h
//  Hiskor
//
//  Created by SuchyMac3 on 1/29/13.
//  Copyright (c) 2013 ITP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkingManager.h"
#import "HomeTableViewController.h"

@interface LoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NetworkingResponseHandler, UITextFieldDelegate>
{
    UITableView *mainLoginInfo;
    UITextField *usernameField;
    UITextField *passwordField;
}

- (IBAction)btnLogin:(id)sender;
- (IBAction)btnKeychainChecker:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end
