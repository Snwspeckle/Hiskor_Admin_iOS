//
//  CheckInViewController.m
//  Hiskor
//
//  Created by SuchyMac3 on 2/28/13.
//  Copyright (c) 2013 ITP. All rights reserved.
//

#import "CheckInViewController.h"
#import "ZBarReaderViewController.h"
#import "ZBarReaderView.h"
#import "TabBarViewController.h"
#import "Lockbox.h"
#import "MBProgressHUD.h"
#import "GamesTableViewCell.h"

#define kUserIDKeyString          @"UserIDKeyString"
#define kLoggedinStatusKeyString    @"LoggedinStatusKeyString"

@interface CheckInViewController ()

@end

@implementation CheckInViewController
@synthesize JSONResponse, gameData, resultText, games;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //NSLog(@"Game Data: %@", gameData);
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadGames {
    
    NSString *userID = [Lockbox stringForKey:kUserIDKeyString];
    NSString *type = @"game";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID, @"userID",
                            type, @"type",
                            nil];
    
	[NetworkingManager sendDictionary:params responseHandler:self];
    
}

- (void)checkTicketForString:(NSString *)ticketCode {
    
    NSString *gameID = [gameData objectForKey:@"gameID"];
    NSString *type = @"checkTicket";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            gameID, @"gameID",
                            ticketCode, @"ticketCode",
                            type, @"type",
                            nil];
    
	[NetworkingManager sendDictionary:params responseHandler:self];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [games count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row%2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:.90 green:.90 blue:.90 alpha:1];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    GamesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *gamesDictionary = [games objectAtIndex:indexPath.row];
    
    [[cell homeLabel] setText:[gamesDictionary objectForKey:@"homeSchool"]];
    [[cell awayLabel] setText:[gamesDictionary objectForKey:@"awaySchool"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_QRCODE config: ZBAR_CFG_ENABLE to: 1];
    
    NSDictionary *game = [games objectAtIndex:indexPath.row];
    gameData = game;

    [self presentModalViewController: reader animated: YES];

}

/*- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"checkIn"]){
        CheckInViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *game = [games objectAtIndex:indexPath.row];
        vc.gameData = game;
    }
}*/

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info {
    // ADD: get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    resultText.text = symbol.data;
    [self checkTicketForString:symbol.data];
    
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    //[reader dismissModalViewControllerAnimated: YES];
}

- (void)networkingResponseReceived:(id)response ForMessage:(NSDictionary *)message {
    
    // Filters the type of response, checks if response is game
    if ([[message valueForKeyPath:@"type"] isEqualToString:@"game"]) {
        
        if ([[response valueForKeyPath:@"message"] isEqualToString:@"Failed"]) {
            
            UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Game pull failed" message:@"An error has occured pulling games" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [loginAlert show];
            
        } else {
            NSLog(@"JSON Response: %@", response);
            JSONResponse = [response copy];
            games = [JSONResponse objectForKey:@"games"];
            [self.tableView reloadData];
        }
    
    // Checks if response is checkTicket
    } else if ([[message valueForKeyPath:@"type"] isEqualToString:@"checkTicket"]) {
        
        if ([[response valueForKeyPath:@"message"] isEqualToString:@"Failed"]) {
            
            /*UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Error Scanning" message:@"An error has occured scanning ticket" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [loginAlert show];*/
            
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.modalViewController.view addSubview:HUD];
            
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"invalid.png"]];
            
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            
            HUD.delegate = self;
            HUD.labelText = @"Invalid";
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
            
        } else {
            NSLog(@"JSON Response: %@", response);
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.modalViewController.view addSubview:HUD];
            
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"valid.png"]];
            
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            
            HUD.delegate = self;
            HUD.labelText = @"Valid";
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
        }
    }
}

- (void)networkingResponseFailedForMessage:(NSDictionary *)message error:(NSError *)error {
	
	NSLog(@"Error with request");
	NSLog(@"%@", [error localizedDescription]);
}

- (IBAction)refreshGames:(id)sender {
    [self loadGames];
}

- (void)refresh {
    [self performSelector:@selector(addItem) withObject:nil afterDelay:2.0];
}

- (void)addItem {
    // Add a new time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *now = [dateFormatter stringFromDate:[NSDate date]];
    [items insertObject:[NSString stringWithFormat:@"%@", now] atIndex:0];
    
    [self loadGames];    
    [self stopLoading];
}

@end
