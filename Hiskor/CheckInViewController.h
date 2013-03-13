//
//  CheckInViewController.h
//  Hiskor
//
//  Created by SuchyMac3 on 2/28/13.
//  Copyright (c) 2013 ITP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarReaderViewController.h"
#import "NetworkingManager.h"
#import "MBProgressHUD.h"
#import "PullRefreshTableViewController.h"

@interface CheckInViewController : PullRefreshTableViewController <ZBarReaderDelegate, NetworkingResponseHandler, MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    long long expectedLength;
	long long currentLength;
    NSMutableArray *items;
}

- (IBAction)btnLogout:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayLabel;

- (void) loadGames;
- (void) checkTicketForString:(NSString *)ticketCode;

@property (nonatomic, assign) BOOL animateBOOL;
@property (nonatomic, strong) NSArray *games;
@property (nonatomic, strong) NSDictionary *JSONResponse;
@property (nonatomic, strong) NSDictionary *gameData;
@property (nonatomic, retain) IBOutlet UITextView *resultText;

@end
