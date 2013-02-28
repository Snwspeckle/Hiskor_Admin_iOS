//
//  HomeTableViewController.m
//  Hiskor
//
//  Created by Anthony on 2/1/13.
//  Copyright (c) 2013 ITP. All rights reserved.
//

#import "HomeTableViewController.h"
#import "TabBarViewController.h"
#import "Lockbox.h"
#import "GamesTableViewCell.h"
#import "CheckInViewController.h"

#define kUserIDKeyString          @"UserIDKeyString"
#define kLoggedinStatusKeyString    @"LoggedinStatusKeyString"

@interface HomeTableViewController ()

@end

@implementation HomeTableViewController
@synthesize animateBOOL, JSONResponse, games;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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

- (void)networkingResponseReceived:(id)response ForMessage:(NSDictionary *)message {
	
	if ([[response valueForKeyPath:@"message"] isEqualToString:@"Failed"]) {
		
		UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Game pull failed" message:@"An error has occured pulling games" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		[loginAlert show];
		
	} else {
        JSONResponse = [response copy];
        games = [JSONResponse objectForKey:@"games"];
		NSLog(@"JSON Response: %@", response);
        [self.tableView reloadData];
	}
}

- (void)networkingResponseFailedForMessage:(NSDictionary *)message error:(NSError *)error {
	
	NSLog(@"Error with request");
	NSLog(@"%@", [error localizedDescription]);
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
    
    [tableView setAllowsSelection:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"checkIn"]){
        CheckInViewController *vc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *game = [games objectAtIndex:indexPath.row];
        vc.gameData = game;
    }
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
