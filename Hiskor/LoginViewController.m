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
#import "TextInputCell.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize btnLogin;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"tasky_pattern.png"]];
    
    // Creates the login form
    mainLoginInfo  = [[UITableView alloc] initWithFrame:CGRectMake(15,110, 300,150) style:UITableViewStyleGrouped];
    mainLoginInfo.dataSource = self;
    mainLoginInfo.delegate = self;
    [self.view addSubview:mainLoginInfo];
    [self.view sendSubviewToBack:mainLoginInfo];

    // Creates the custom button
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    // Set the background for any states you plan to use
    [btnLogin setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [btnLogin setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    mainLoginInfo.backgroundView = nil;
    mainLoginInfo.scrollEnabled = NO;
    
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
    
    if ([usernameField.text isEqualToString:@""] || !usernameField.text || [passwordField.text isEqualToString:@""] || !passwordField.text) {
        
        UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Error logging in" message:@"Email or password cannot be blank" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		[loginAlert show];
        
    } else {
        
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 48.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TextInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
    
    tableView.separatorStyle= UITableViewCellSeparatorStyleSingleLine;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:.874 green:.874 blue:.874 alpha:1];
    
    switch (indexPath.row) {
        case 0:
            
            usernameField = cell.textField;
            usernameField.placeholder = @"Email";
            usernameField.textColor = [UIColor blackColor];
            usernameField.clearButtonMode  = UITextFieldViewModeWhileEditing;
            usernameField.font = [UIFont fontWithName:@"Helvetica" size:16.0];
            usernameField.keyboardType = UIKeyboardTypeEmailAddress;
            usernameField.delegate = self;
            [cell.contentView addSubview:usernameField];
            break;
        case 1:
            passwordField = cell.textField;
            passwordField.placeholder = @"Password";
            passwordField.textColor = [UIColor blackColor];
            passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
            passwordField.secureTextEntry = YES;
            passwordField.font = [UIFont fontWithName:@"Helvetica" size:16.0];
            passwordField.returnKeyType = UIReturnKeyGo;
            passwordField.delegate = self;
            [cell.contentView addSubview:passwordField];
            
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == usernameField) {
        [passwordField becomeFirstResponder];
    }
    else if (textField == passwordField) {
        [textField resignFirstResponder];
        [self btnLogin:nil];
    }
    return YES;
}

- (void)networkingResponseReceived:(id)response ForMessage:(NSDictionary *)message {
	
	NSLog(@"UserID: %@", [response valueForKeyPath:@"userID"]);
	NSLog(@"Token: %@", [response valueForKeyPath:@"token"]);
	NSLog(@"Return Message: %@", [response valueForKeyPath:@"message"]);
	
	if ([[response valueForKeyPath:@"message"] isEqualToString:@"Failed"]) {
		
		UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Error logging in" message:@"Invalid email or password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		[loginAlert show];
		
	} else {
		
		// Save userID to keychain
		[Lockbox setString:[response valueForKeyPath:@"userID"] forKey:kUserIDKeyString];
		
		// Save token to keychain
		[Lockbox setString:[response valueForKeyPath:@"token"] forKey:kTokenKeyString];
		
		// Save login status to keychain
		[Lockbox setString:@"TRUE" forKey:kLoggedinStatusKeyString];
        
        // Calls the loadGames method in CheckInViewController
        UITabBarController *tabBarController = (UITabBarController *)self.presentingViewController;
        
        UINavigationController *navController = [tabBarController.viewControllers objectAtIndex:0];
        UINavigationController *settingsNavController = [tabBarController.viewControllers objectAtIndex:1];
        
        CheckInViewController *checkInViewController = [navController.viewControllers objectAtIndex:0];
        SettingsTableViewController *settingsTableViewController = [settingsNavController.viewControllers objectAtIndex:0];
        
        [checkInViewController loadGames];
        [settingsTableViewController loadSettings];
		
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)networkingResponseFailedForMessage:(NSDictionary *)message error:(NSError *)error {
	
	NSLog(@"Error with request");
	NSLog(@"%@", [error localizedDescription]);
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
