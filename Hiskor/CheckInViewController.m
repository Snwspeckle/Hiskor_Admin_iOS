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
#import "GamesTableViewCell.h"

#define kUserIDKeyString          @"UserIDKeyString"
#define kLoggedinStatusKeyString    @"LoggedinStatusKeyString"

@interface CheckInViewController ()

@end

@implementation CheckInViewController
@synthesize JSONResponse, gameData, resultText, animateBOOL, games;

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
    //NSLog(@"Game Data: %@", gameData);
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
    //[self performSegueWithIdentifier:@"checkIn" sender:indexPath];
    
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
            
            UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Error Scanning" message:@"An error has occured scanning ticket" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [loginAlert show];
            
        } else {
            NSLog(@"JSON Response: %@", response);
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

- (IBAction)btnLogout:(id)sender {
    
    self.animateBOOL = YES;
    [Lockbox setString:@"FALSE" forKey:kLoggedinStatusKeyString];
    [(TabBarViewController *)[self tabBarController] loginCheck:self.animateBOOL];
}

@end
