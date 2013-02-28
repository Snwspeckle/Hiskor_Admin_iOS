//
//  HomeTableViewController.h
//  Hiskor
//
//  Created by Anthony on 2/1/13.
//  Copyright (c) 2013 ITP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkingManager.h"

@interface HomeTableViewController : UITableViewController <NetworkingResponseHandler>
- (IBAction)refreshGames:(id)sender;
- (IBAction)btnLogout:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayLabel;

- (void) loadGames;

@property (nonatomic, assign) BOOL animateBOOL;
@property (nonatomic, strong) NSDictionary *JSONResponse;
@property (nonatomic, strong) NSArray *games;

@end
