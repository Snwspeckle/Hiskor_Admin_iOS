//
//  SettingsTableViewController.h
//  Hiskor Admin
//
//  Created by SuchyMac3 on 3/13/13.
//  Copyright (c) 2013 ITP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkingManager.h"

@interface SettingsTableViewController : UITableViewController <NetworkingResponseHandler>

- (IBAction)btnLogout:(id)sender;

- (void) loadSettings;

@property (nonatomic, assign) BOOL animateBOOL;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelSchool;

@property (nonatomic, strong) NSDictionary *JSONResponse;
@property (nonatomic, strong) NSArray *settings;

@end
