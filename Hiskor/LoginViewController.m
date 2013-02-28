//
//  LoginViewController.m
//  Hiskor
//
//  Created by SuchyMac3 on 1/29/13.
//  Copyright (c) 2013 ITP. All rights reserved.
//

#import "LoginViewController.h"
#import "Lockbox.h"
#import <CommonCrypto/CommonDigest.h>

#define kUserIDKeyString          @"UserIDKeyString"
#define kTokenKeyString             @"TokenKeyString"
#define kLoggedinStatusKeyString    @"LoggedinStatusKeyString"
#define salt                        @"FSF^D&*FH#RJNF@!$JH#@$"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize usernameField, passwordField;

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.view endEditing:TRUE];
}

- (IBAction)btnLogin:(id)sender {
    
    NSString *email = [usernameField text];
    NSString *password = [passwordField text];
    NSString *type = @"login";
    
    // Hashing Algorithm
    NSString *saltPassword = [password stringByAppendingString:salt];
    NSString *passwordMD5 = [self md5:saltPassword];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            passwordMD5, @"passwordMD5",
                            type, @"type",
                            nil];
    
	[NetworkingManager sendDictionary:params responseHandler:self];
    
}

- (void)networkingResponseReceived:(id)response ForMessage:(NSDictionary *)message {
	
	NSLog(@"UserID: %@", [response valueForKeyPath:@"userID"]);
	NSLog(@"Token: %@", [response valueForKeyPath:@"token"]);
	NSLog(@"Return Message: %@", [response valueForKeyPath:@"message"]);
	
	if ([[response valueForKeyPath:@"message"] isEqualToString:@"Failed"]) {
		
		UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Error logging in" message:@"Invalid email or password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		[loginAlert show];
		
	} else {
		
		UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Login Success" message:@"Proper login, thanks!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		[loginAlert show];
		
		// Save userID to keychain
		[Lockbox setString:[response valueForKeyPath:@"userID"] forKey:kUserIDKeyString];
		
		// Save token to keychain
		[Lockbox setString:[response valueForKeyPath:@"token"] forKey:kTokenKeyString];
		
		// Save login status to keychain
		[Lockbox setString:@"TRUE" forKey:kLoggedinStatusKeyString];
        
        // Calls the loadGames method in HomeTableViewController
        UITabBarController *tabBarController = (UITabBarController *)self.presentingViewController;
        
        UINavigationController *navController = [tabBarController.viewControllers objectAtIndex:0];
        
        HomeTableViewController *homeViewController =[navController.viewControllers objectAtIndex:0];
        
        [homeViewController loadGames];
		
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)networkingResponseFailedForMessage:(NSDictionary *)message error:(NSError *)error {
	
	NSLog(@"Error with request");
	NSLog(@"%@", [error localizedDescription]);
}

// Keychain Checker Function
- (IBAction)btnKeychainChecker:(id)sender {
    
    NSLog(@"Keychain UserID: %@", [Lockbox stringForKey:kUserIDKeyString]);
    NSLog(@"Keychain token: %@", [Lockbox stringForKey:kTokenKeyString]);
    NSLog(@"Keychain login status: %@", [Lockbox stringForKey:kLoggedinStatusKeyString]);

}


// MD5 Hashing Function
- (NSString *)md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
@end
