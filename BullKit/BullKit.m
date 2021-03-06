//
//  BullKit.m
//  BullKit
//
//  Created by Rohan Parolkar on 1/21/15.
//  Copyright (c) 2015 raklorap. All rights reserved.
//

#import "BullKit.h"

static NSUInteger timout = 10;

@interface BullKit()

- (NSMutableData *)encodeRequestParams:(NSDictionary *)params;
- (NSString *)encodeString:(NSString *)unencodedString;

- (void)notifyDelegateOfSuccess;
- (void)notifyDelegateOfError:(NSError *)error;
- (void)cleanup;
@end


@implementation BullKit

@synthesize urlString = _urlString;
@synthesize apiUrl = _apiUrl;
@synthesize delegate = _delegate;
@synthesize responseData = _responseData;
@synthesize userInfo = _userInfo;
@synthesize responseString = _responseString;
@synthesize responseStatusCode = _responseStatusCode;
@synthesize error = _error;

+ (void)setTimeout:(NSUInteger)tout {
    timout = tout;
}

#pragma mark - Initialization

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if (self != nil) {
        self.apiUrl  = @"https://CampBX.com/api/%@.php";
        self.delegate = aDelegate;
        self.responseData = [NSMutableData data];
    }
    return self;
}

#pragma mark - Setup

- (NSData *)encodeRequestParams:(NSDictionary *)params {
    NSString *postString = @"";
    for (NSString *key in params.allKeys) {
        if  (postString.length>0) postString = [postString stringByAppendingString:@"&"];
        postString = [postString stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,[params objectForKey:key]]];
    }
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    return postData;
}

- (void)callApiMethod:(NSString *)method withParams:(NSDictionary *)params {
    [self cancel];
    
    self.urlString = [NSString stringWithFormat:self.apiUrl, method];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:timout];
    
    if (params) {
        NSData *postData = [self encodeRequestParams:params];
        [request setHTTPBody:postData];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
}

- (void)getDepthTable {
    [self callApiMethod:@"xdepth" withParams:nil];
}
- (void)getMarketTicker {
    [self callApiMethod:@"xticker" withParams:nil];
}
- (void)getAccountBalancesForUser:(NSString *)username WithPassword:(NSString *)password {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"user",password,@"pass", nil];
    [self callApiMethod:@"myfunds" withParams:params];
}

- (void)getOrdersForUser:(NSString *)username WithPassword:(NSString *)password {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"user",password,@"pass", nil];
    [self callApiMethod:@"myorders" withParams:params];
}

- (void)getMarginsForUser:(NSString *)username WithPassword:(NSString *)password {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"user",password,@"pass", nil];
    [self callApiMethod:@"mymargins" withParams:params];
}

- (void)getNewBitcoinDepositAddressForUser:(NSString *)username WithPassword:(NSString *)password {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"user",password,@"pass", nil];
    [self callApiMethod:@"getbtcaddr" withParams:params];
}

- (void)sendBitcoinsTo:(NSString *)bitcoinAddress amount:(NSDecimalNumber *)amount user:(NSString *)username password:(NSString *)password {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"user",password,@"pass",bitcoinAddress,@"BTCTo",amount,@"BTCAmt", nil];
    [self callApiMethod:@"sendbtc" withParams:params];
}

- (void)buyBitcoinsAt:(NSNumber *)price amount:(NSDecimalNumber *)amount user:(NSString *)username password:(NSString *)password {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"user",password,@"pass",@"QuickBuy",@"TradeMode",amount,@"Quantity",price,@"Price", nil];
    [self callApiMethod:@"tradeenter" withParams:params];
}

- (void)sellBitcoinsAt:(NSNumber *)price amount:(NSDecimalNumber *)amount user:(NSString *)username password:(NSString *)password {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"user",password,@"pass",@"QuickSell",@"TradeMode",amount,@"Quantity",price,@"Price", nil];
    [self callApiMethod:@"tradeenter" withParams:params];
}

- (void)cancelOrderWithID:(NSInteger)numericID type:(tradeType)type user:(NSString *)username password:(NSString *)password {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"user",password,@"pass",[BullKit convertToString:type],@"Type",numericID,@"OrderID", nil];
    [self callApiMethod:@"tradecancel" withParams:params];
}

#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseStatusCode = [((NSHTTPURLResponse *)response) statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self notifyDelegateOfSuccess];
    [self cleanup];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self notifyDelegateOfError:error];
    [self cleanup];
}

#pragma mark - Helpers

- (void)notifyDelegateOfSuccess {
    _responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(bkRequestSucceeded:)]) {
        [self.delegate performSelector:@selector(bkRequestSucceeded:) withObject:self];
    }
}

- (void)notifyDelegateOfError:(NSError *)error {
    _error = error;
    
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(bkRequestFailed:andError:)]) {
        [self.delegate performSelector:@selector(bkRequestFailed:andError:) withObject:self withObject:error];
    } else if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(bkRequestFailed:)]) {
        [self.delegate performSelector:@selector(bkRequestFailed:) withObject:error];
    }
}

- (NSString *)encodeString:(NSString *)unencodedString {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                    (__bridge CFStringRef)unencodedString,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8));
    return encodedString;
}

- (void)cleanup {
    [self.responseData setLength:0];
}
#pragma mark - Internal

+ (NSString*) convertToString:(tradeType) tradeType {
    NSString *result = nil;
    
    switch(tradeType) {
        case Buy:
            result = @"Buy";
            break;
        case Sell:
            result = @"Sell";
            break;
        default:
            result = @"unknown";
    }
    
    return result;
}

@end
