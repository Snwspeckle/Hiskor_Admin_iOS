//
//  NetworkingManager.m
//  Hiskor
//
//  Created by Landon on 2/21/13.
//  Copyright (c) 2013 ITP. All rights reserved.
//

#import "NetworkingManager.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"

@implementation NetworkingManager

+ (void)sendDictionary:(NSDictionary *)dictionary responseHandler:(id<NetworkingResponseHandler>)responseHandler {
		
	NSDictionary *message = [dictionary copy];
		
	// Sends request to server to login, server sends response via JSON
    NSURL *url = [NSURL URLWithString:@"http://192.168.0.100/Hiskor_Admin"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"api.php" parameters:message];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		[responseHandler networkingResponseReceived:JSON ForMessage:message];
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
			[responseHandler networkingResponseFailedForMessage:message error:error];
		}];
    
    [operation start];
}


@end
