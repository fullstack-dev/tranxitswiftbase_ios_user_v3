//
//  PayUServiceHelper.m
//  EimarsMLM
//
//  Created by Vasu Saini on 22/11/17.
//  Copyright © 2017 oodlesTechnologies_Vasu_Saini. All rights reserved.
//

#import "PayUServiceHelper.h"
#import <PlugNPlay/PlugNPlay.h>

@interface PayUServiceHelper()
@property (nonatomic, strong) PayUCompletionBlock completionBlock;
@property (nonatomic, strong) PayUFailuerBlock failuerBlock;
@property (nonatomic, strong) UIViewController *parentController;
@property (nonatomic, strong) NSString *payu_salt;
@end

@implementation PayUServiceHelper

+ (PayUServiceHelper *)sharedManager {
    static PayUServiceHelper *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[PayUServiceHelper alloc] init];
    });
    return _sharedManager;
}

-(void) getPayment:(UIViewController*)controller :(NSString*)email :(NSString*)phone :(NSString*)name :(NSString*)amount :(NSString*)trxnID :(NSString*)merchantid :(NSString*)KEY :(NSString*)merchantSalt :(NSString*)surl :(NSString*)furl productInfo:(NSString *) productInfo udf1 : (NSString *) udf1 didComplete:(PayUCompletionBlock)getPaymentBlock didFail:(PayUFailuerBlock)failBlock{
    self.completionBlock = getPaymentBlock;
    self.failuerBlock = failBlock;
    self.parentController = controller;
    [self setParam:email :phone :name :amount :trxnID :KEY :merchantid :merchantSalt :surl :furl productInfo:productInfo udf1:udf1];
}

- (void)setParam: (NSString*)email : (NSString*)phone : (NSString*)firstName :(NSString*)amount :(NSString*)trxnID :(NSString*)KEY :(NSString*)merchantid :(NSString*)merchantSalt :(NSString*)surl :(NSString*)furl  productInfo:(NSString *) productInfo udf1 : (NSString *) udf1 {
    PUMTxnParam *txnParam= [[PUMTxnParam alloc] init];
    
    
#pragma mark Sandbox Crenditials
    txnParam.environment = PUMEnvironmentTest;
    txnParam.key = KEY;
    txnParam.merchantid = merchantid;
    self.payu_salt = merchantSalt;

#pragma mark Production Crenditials
//    txnParam.environment = PUMEnvironmentProduction;
//    txnParam.key = @"";
//    txnParam.merchantid = @"";
//    self.payu_salt = @"";
//    txnParam.environment = PUMEnvironmentProduction;
//    txnParam.key = KEY;
//    txnParam.merchantid = merchantid; //@"6299824";
//    self.payu_salt = merchantSalt;

    
    
    txnParam.phone = phone;
    txnParam.email = email;
    txnParam.amount = amount;
    txnParam.firstname = firstName;
    txnParam.txnID = trxnID;
    txnParam.surl = surl;
    txnParam.furl = furl;
    txnParam.productInfo = productInfo;
    txnParam.udf1 = udf1;
    txnParam.udf2 = @"NA";
    txnParam.udf3 = @"NA";
    txnParam.udf4 = @"NA";
    txnParam.udf5 = @"NA";
    txnParam.udf6 = @"NA";
    txnParam.udf7 = @"NA";
    txnParam.udf8 = @"NA";
    txnParam.udf9 = @"NA";
    txnParam.udf10 = @"NA";
    txnParam.hashValue = [self getHashForPaymentParams:txnParam];
   
    [PlugNPlay setDisableCompletionScreen:NO];  
   // [PlugNPlay setDisableCards:NO];
   // [PlugNPlay setDisableNetbanking:NO];
  //  [PlugNPlay setDisableWallet:YES];
    [PlugNPlay disableCompletionScreen];
    [PlugNPlay setMerchantDisplayName:@"PayUmoney"];
    
    [PlugNPlay presentPaymentViewControllerWithTxnParams:txnParam onViewController:_parentController withCompletionBlock:^(NSDictionary *paymentResponse, NSError *error, id extraParam) {
        if (!error) {
            NSLog(@" Sucess Response--->>>   %@",paymentResponse);
            self.completionBlock(paymentResponse, error);
        } else {
            NSLog(@" Failuer Response--->>>   %@",paymentResponse);
            NSLog(@" Failuer Error--->>>   %@",error);
            [UIUtility toastMessageOnScreen:[error localizedDescription]];
            self.failuerBlock(error);
            
        }
        
    }];
}


-(void)logOut{
    if ([PayUMoneyCoreSDK isUserSignedIn]) {
//#warning CODE TO BE REMOVED BEFORE GOING LIVE
        [PayUMoneyCoreSDK signOut];
    }
}


-(NSString*)getHashForPaymentParams:(PUMTxnParam*)txnParam {
    
    NSString *salt = self.payu_salt;
    NSString *hashSequence = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@",txnParam.key,txnParam.txnID,txnParam.amount,txnParam.productInfo,txnParam.firstname,txnParam.email,txnParam.udf1,txnParam.udf2,txnParam.udf3,txnParam.udf4,txnParam.udf5,txnParam.udf6,txnParam.udf7,txnParam.udf8,txnParam.udf9,txnParam.udf10, salt];
    NSString *hash = [[[[[self createSHA512:hashSequence] description]stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
    return hash;
}

- (NSString*) createSHA512:(NSString *)source {
    
    const char *s = [source cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH] = {0};
    CC_SHA512(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *output = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    NSLog(@"Hash output --------- %@",output);
    NSString *hash =  [[[[output description]stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
    return hash;
}


/*
 //Call this method as follows in swift 4
 
 PayUServiceHelper.sharedManager().getPayment("Controller", "mail@mymail.com", "+91-9896952757", "Name", "Amount 0011", didComplete: { (dict, error) in
 if let error = error {
 let _ = AlertController.alert("Error!", message: (error.localizedDescription))
 }else {
 }
 }) { (error) in
 }
 
 */

@end
