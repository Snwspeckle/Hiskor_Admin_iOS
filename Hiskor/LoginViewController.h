//
//  LoginViewController.h
//  Hiskor
//
//  Created by SuchyMac3 on 1/29/13.
//  Copyright (c) 2013 ITP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkingManager.h"

@interface LoginViewController : UIViewController <NetworkingResponseHandler>
- (IBAction)btnLogin:(id)sender;
- (IBAction)btnKeychainChecker:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end
