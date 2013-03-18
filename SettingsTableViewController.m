//
//  SettingsTableViewController.m
//  Hiskor Admin
//
//  Created by SuchyMac3 on 3/13/13.
//  Copyright (c) 2013 ITP. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "TabBarViewController.h"
#import "Lockbox.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController
@synthesize animateBOOL, labelEmail, labelSchool, JSONResponse, settings;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[Lockbox stringForKey:@"LoggedinStatusKeyString"] isEqualToString:@"TRUE"]) {
        [self loadSettings];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)loadSettings {
    
    NSString *userID = [Lockbox stringForKey:kUserIDKeyString];
    NSString *type = @"settings";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID, @"userID",
                            type, @"type",
                            nil];
    
	[NetworkingManager sendDictionary:params responseHandler:self];
    
}

- (void)networkingResponseReceived:(id)response ForMessage:(NSDictionary *)message {
    
        if ([[response valueForKeyPath:@"message"] isEqualToString:@"Failed"]) {
            
            UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Settings pull failed" message:@"An error has occured pulling games" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [loginAlert show];
            
        } else {
            JSONResponse = [response copy];
            labelEmail.text = [JSONResponse objectForKey:@"email"];
            labelSchool.text = [JSONResponse objectForKey:@"schoolName"];
            [self.tableView reloadData];
        }
}

- (void)networkingResponseFailedForMessage:(NSDictionary *)message error:(NSError *)error {
	
	NSLog(@"Error with request");
	NSLog(@"%@", [error localizedDescription]);
}

- (IBAction)btnLogout:(id)sender {
    
    self.animateBOOL = YES;
    [Lockbox setString:@"FALSE" forKey:kLoggedinStatusKeyString];
    [(TabBarViewController *)[self tabBarController] loginCheck:self.animateBOOL];
}
    
@end