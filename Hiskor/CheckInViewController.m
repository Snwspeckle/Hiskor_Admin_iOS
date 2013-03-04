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

@interface CheckInViewController ()

@end

@implementation CheckInViewController
@synthesize JSONResponse, gameData, resultText;

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
    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_QRCODE config: ZBAR_CFG_ENABLE to: 1];
    [self presentModalViewController: reader animated: YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    [reader dismissModalViewControllerAnimated: YES];
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

- (void)networkingResponseReceived:(id)response ForMessage:(NSDictionary *)message {
	
	if ([[response valueForKeyPath:@"message"] isEqualToString:@"Failed"]) {
		
		UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Game pull failed" message:@"An error has occured pulling games" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		[loginAlert show];
		
	} else {
		NSLog(@"JSON Response: %@", response);
	}
}

- (void)networkingResponseFailedForMessage:(NSDictionary *)message error:(NSError *)error {
	
	NSLog(@"Error with request");
	NSLog(@"%@", [error localizedDescription]);
}

@end
