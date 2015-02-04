//
//  BullKit.h
//  BullKit
//
//  Created by Rohan Parolkar on 1/21/15.
//  Copyright (c) 2015 raklorap. All rights reserved.
//


#import <Foundation/Foundation.h>

@class BullKit;

@protocol BullKitDelegate <NSObject>

@optional
- (void)bkRequestSucceeded:(BullKit *)bkRequest;

@optional
- (void)bkRequestFailed:(NSError *)error;

@optional
- (void)bkRequestFailed:(BullKit *)bkRequest andError:(NSError *)error;

@end

@interface BullKit : NSOperation {
    id<BullKitDelegate> __unsafe_unretained delegate;
    SEL onSuccess;
    SEL onFailure;
    
    NSString *apiUrl;
    NSString *urlString;
    id userInfo;
    
@private
    NSMutableData *responseData;
}

typedef enum {
    Buy,
    Sell
}tradeType;

@property (nonatomic, strong) NSString *urlString;
@property (unsafe_unretained, readwrite) id<BullKitDelegate> delegate;
@property (nonatomic, strong) id userInfo;

@property (nonatomic, strong) NSString *apiUrl;

@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, readonly) NSString *responseString;
@property (nonatomic, readonly) NSInteger responseStatusCode;
@property (nonatomic, readonly) NSError *error;

+ (void)setTimeout:(NSUInteger)tout;

- (id)initWithDelegate:(id)aDelegate;

- (void)getDepthTable;
- (void)getMarketTicker;
- (void)getAccountBalancesForUser:(NSString *)username WithPassword:(NSString *)password;
- (void)getOrdersForUser:(NSString *)username WithPassword:(NSString *)password;
- (void)getMarginsForUser:(NSString *)username WithPassword:(NSString *)password;
- (void)getNewBitcoinDepositAddressForUser:(NSString *)username WithPassword:(NSString *)password;

- (void)sendBitcoinsTo:(NSString *)bitcoinAddress amount:(NSDecimalNumber *)amount user:(NSString *)username password:(NSString *)password;
- (void)buyBitcoinsAt:(NSNumber *)price amount:(NSDecimalNumber *)amount user:(NSString *)username password:(NSString *)password;
- (void)sellBitcoinsAt:(NSNumber *)price amount:(NSDecimalNumber *)amount user:(NSString *)username password:(NSString *)password;

- (void)cancelOrderWithID:(NSInteger)numericID type:(tradeType)type user:(NSString *)username password:(NSString *)password; //tradecancel

@end