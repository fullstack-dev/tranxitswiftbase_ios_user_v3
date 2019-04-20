//
//  PayUServiceHelper.h
//  EimarsMLM
//
//  Created by Vasu Saini on 22/11/17.
//  Copyright © 2017 oodlesTechnologies_Vasu_Saini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>



typedef void (^PayUCompletionBlock) (NSDictionary *dict, NSError *error );
typedef void (^PayUFailuerBlock)(NSError *error );


@interface PayUServiceHelper : NSObject

- (void)logOut;
- (void)getPayment:(UIViewController *)controller :(NSString*)email :(NSString*)phone :(NSString*)name :(NSString*)amount :(NSString*)trxnID :(NSString*)merchantid :(NSString*)KEY :(NSString*)merchantSalt :(NSString*)surl :(NSString*)furl productInfo:(NSString *) productInfo udf1 : (NSString *) udf1 didComplete:(PayUCompletionBlock)getPaymentBlock didFail:(PayUFailuerBlock)failBlock;
+ (PayUServiceHelper *)sharedManager;

@end
