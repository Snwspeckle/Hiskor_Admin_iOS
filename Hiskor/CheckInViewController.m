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
@synthesize gameData, resultText;

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
    NSLog(@"Game Data: %@", gameData);
    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    [reader.scanner setSymbology: ZBAR_QRCODE config: ZBAR_CFG_ENABLE to: 0];
    reader.readerView.zoom = 1.0;
    [self presentModalViewController: reader animated: YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info {
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
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

@end