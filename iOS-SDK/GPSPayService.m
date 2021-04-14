
#import "GPSPayService.h"
#import "GPSPaymentResponse.h"
#import "GPSHelpers.h"
#import "GPSSigner.h"
#import "GPSRestRequester.h"
#import "GPSConnectionProfile.h"
#import "GPSTransactionDetails.h"
#import "GPSReccurentParams.h"
#import "GPSInvoiceData.h"

static NSString *version = @"2.1";

@interface GPSPayService ()

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *secret;
@property (nonatomic, copy) NSString *serviceId;

@end

@implementation GPSPayService

// Version 2.0
- (NSString *) generateCheck: (NSDictionary *)requestParams {
    
    //
    NSString * string = @"";
    string = [string stringByAppendingFormat: @"%@%@", self.serviceId, self.secret];
    string = [string md5];
    
    return string;
}

- (instancetype)initWithServiceId:(NSString *)serviceId andSecret:(NSString *)secret {
    
    self = [super init];
    
    if (self) {
        self.serviceId = serviceId;
        self.secret = secret;
    }
    
    return self;
}

- (instancetype)initWithServiceId:(NSString *)serviceId andKey:(NSString *)key
{
    self = [super init];
    
    if (self) {
        self.serviceId = serviceId;
        self.key = key;
    }
    
    return self;
}


+ (NSString *) generateUrlForRequest: (RFIPaymentRequest *)paymentRequest {
    
    return @"";
}

//
// Init payment
//

- (void)paymentInit:(GPSPaymentRequest *)paymentRequest
       successBlock:(serviceSuccessBlock)success
            failure:(errorBlock)failure {
    
    NSMutableDictionary *params = [@{@"version": version} mutableCopy];
    
    if (self.serviceId && self.key) {
        params[@"key"] = self.key;
    } else if (self.serviceId && self.secret) {
        params[@"service_id"] = self.serviceId;
    } else {
        if (failure) {
            NSString *errorMessage = @"GPSPayService should be initialized by key or secret parameter.";
            failure(@{@"Error": errorMessage});
        }
        return;
    }
    
    return [self paymentInitWithRequest:paymentRequest
                              andParams:[params copy]
                           successBlock:success
                                failure:failure];
}

//
// Init payment with params
//

- (void)paymentInitWithRequest:(GPSPaymentRequest *)paymentRequest
                     andParams:(NSDictionary *)params
                  successBlock:(serviceSuccessBlock)success
                       failure:(errorBlock)failure
{
    NSMutableDictionary * requestMutableParams = [params mutableCopy];
    
    requestMutableParams[@"payment_type"] = paymentRequest.paymentType;
    requestMutableParams[@"cost"] = paymentRequest.cost;
    requestMutableParams[@"name"] = paymentRequest.name;
    
    if (paymentRequest.email) {
        requestMutableParams[@"email"] = paymentRequest.email;
    }
    
    if (paymentRequest.phone) {
        requestMutableParams[@"phone_number"] = paymentRequest.phone;
    }
    
    if (paymentRequest.orderId) {
        requestMutableParams[@"order_id"] = paymentRequest.orderId;
    }
    
    if (paymentRequest.cardToken) {
        requestMutableParams[@"card_token"] = paymentRequest.cardToken;
    }
    
    if (paymentRequest.comment) {
        requestMutableParams[@"comment"] = paymentRequest.comment;
    }
    
    NSString *background = paymentRequest.background ? paymentRequest.background : @"0";
    requestMutableParams[@"background"] = background;
    
    if (paymentRequest.commissionMode) {
        requestMutableParams[@"commission"] = paymentRequest.commissionMode;
    }
    
    if (paymentRequest.reccurentParams) {
        if (paymentRequest.reccurentParams.type == GPSReccurentTypeFirst) {
            requestMutableParams[@"recurrent_type"] = @"first";
            requestMutableParams[@"recurrent_comment"] = paymentRequest.reccurentParams.comment;
            requestMutableParams[@"recurrent_url"] = paymentRequest.reccurentParams.url;
            requestMutableParams[@"recurrent_period"] = paymentRequest.reccurentParams.period;
        } else {
            if (!paymentRequest.background) {
                if (failure) {
                    NSString *errorMessage = @"When recurrent_type is \"next\" then background should be \"1\"";
                    failure(@{@"Error": errorMessage});
                }
                return;
            }
            requestMutableParams[@"recurrent_type"] = @"next";
            requestMutableParams[@"recurrent_order_id"] = paymentRequest.reccurentParams.orderId;
        }
    }
    
    if (paymentRequest.invoiceData) {
        requestMutableParams[@"invoice_data"] = [paymentRequest.invoiceData parameters];
    }
    
    // Init payment
    
    NSDictionary *requestParams = [requestMutableParams copy];
    
    NSString *hostUrl =  [GPSConnectionProfile baseUrl];
    NSString *url = [hostUrl stringByAppendingString:@"input"];
    
    [GPSRestRequester request:url andMethod:@"POST" andParams:requestParams andSecret:self.secret successBlock:^(NSDictionary *result) {
        if (success) {
            GPSPaymentResponse * paymentResponse = [[GPSPaymentResponse alloc] initWithRequest:result];
            if (paymentResponse.hasErrors) {
                if (failure) {
                    failure(@{@"Error": result});
                }
            } else {
                success(paymentResponse);
            }
        }
    } failure:failure];
}

//
// Get card token
//

- (void)createCardToken:(GPSCardTokenRequest *)request
                 isTest:(BOOL)isTest
           successBlock:(cardTokenSuccessBlock)success
                failure:(errorBlock)failure {
    
    NSDictionary *requestParams = @{
                                    @"card": request.card,
                                    @"service_id": self.serviceId,
                                    @"exp_month": request.expMonth,
                                    @"exp_year": request.expYear,
                                    @"cvc": request.cvc
                                    };
    
    NSString *hostUrl = @"";
    if(isTest) {
        hostUrl = [hostUrl stringByAppendingString:[GPSConnectionProfile cardTokenTestUrl]];
    } else {
        hostUrl = [hostUrl stringByAppendingString:[GPSConnectionProfile cardTokenUrl]];
    }
    
    NSString *url = [hostUrl stringByAppendingString:@"create"];
    
    [GPSRestRequester request:url andMethod:@"POST" andParams:requestParams andSecret:self.secret successBlock:^(NSDictionary *result) {
        if (success) {
            GPSCardTokenResponse * cardTokenResponse = [[GPSCardTokenResponse alloc] initWithRequest:result];
            if (cardTokenResponse.hasErrors) {
                if (failure) {
                    failure(cardTokenResponse.errors);
                }
            } else {
                success(cardTokenResponse);
            }
        }
    } failure:failure];
}

//
// Get transaction details
//

- (void)transactionDetailsWithSessionKey:(NSString *)sessionKey
                            successBlock:(transactionSuccessBlock)success
                                 failure:(errorBlock)failure {
    
    NSDictionary *requestParams = @{
                                    @"version": version,
                                    @"session_key": sessionKey
                                    };
    
    NSString *hostUrl = [GPSConnectionProfile baseUrl];
    NSString *url = [hostUrl stringByAppendingString:@"details"];
    
    [GPSRestRequester request:url andMethod:@"POST" andParams:requestParams andSecret:nil successBlock:^(NSDictionary *result) {
        if (success) {
            GPSTransactionDetails *transactionDetails = [[GPSTransactionDetails alloc] initWithReponse:result];
            success(transactionDetails);
        }
    } failure:failure];
}

// Cancel recurrent payment
- (void)cancelRecurrentPaymentWithOrderId:(NSString *)orderId
                             successBlock:(cancelationSuccessBlock)success
                                  failure:(errorBlock)failure {
    NSMutableDictionary *params = [@{
                                     @"operation": @"cancel",
                                     @"order_id": orderId,
                                     @"version": version
                                     } mutableCopy];
    
    if (self.serviceId && self.key) {
        params[@"key"] = self.key;
    } else if (self.serviceId && self.secret) {
        params[@"service_id"] = self.serviceId;
    }
    
    NSString *url = [[GPSConnectionProfile baseUrl] stringByAppendingString:@"recurrent_change/"];
    
    [GPSRestRequester request:url andMethod:@"POST" andParams:[params copy] andSecret:self.secret successBlock:^(NSDictionary *result) {
        NSString *status = result[@"status"];
        if ([status isEqualToString:@"success"]) {
            if (success) {
                success();
            }
        } else {
            if (failure) {
                NSDictionary *error = result[@"error"];
                failure(error);
            }
        }
    } failure:failure];
}

@end
