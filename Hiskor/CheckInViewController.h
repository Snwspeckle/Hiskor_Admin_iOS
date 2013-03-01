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

@interface CheckInViewController : UIViewController <ZBarReaderDelegate, NetworkingResponseHandler>

- (void) checkTicketForString:(NSString *)ticketCode;

@property (nonatomic, strong) NSDictionary *gameData;
@property (nonatomic, retain) IBOutlet UITextView *resultText;

@end
