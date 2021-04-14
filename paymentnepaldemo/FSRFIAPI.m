
#import "FSGPSAPI.h"
#import "GPSPay.h"
#import "GPSCardTokenRequest.h"
#import "GPSCardTokenResponse.h"
#import "GPSSigner.h"
#import "GPSTransactionDetails.h"
#import "GPSReccurentParams.h"

#define FS_ERROR_TITLE @"Payment error"
#define FS_EROR_UNKNOWN_ERROR @"Unknown error"

@interface FSGPSAPI()

@property (nonatomic, strong) NSString *serviceId;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic) BOOL testMode;

@property (nonatomic, strong) NSString *lastTransactionId;
@property (nonatomic, strong) NSString *sessionKey;

@end

@implementation FSGPSAPI
    
- (id) initWithServideId: (id) serviceId key: (NSString *) key andTestMode: (BOOL) testMode
    {
        self = [super init];
        
        if (self)
        {
            _serviceId = [NSString stringWithFormat:@"%@", serviceId];
            _key = key;
            _testMode = testMode;
        }
        
        return self;
    }

- (id) initWithServideId: (id) serviceId secret: (NSString *) secret andTestMode: (BOOL) testMode
{
    self = [super init];
    
    if (self)
    {
        _serviceId = [NSString stringWithFormat:@"%@", serviceId];
        _secret = secret;
        _testMode = testMode;
    }
    
    return self;
}

#pragma mark Payment

- (void) makeReccurentPayment: (NSString *) recurrentOrderId orderId: (NSString *) orderId  orderName: (NSString *) orderName comment: (NSString *) comment andSum: (NSNumber *) sum
             successCallback: (void (^)()) success failCallback: (void (^)(NSError *error)) fail
{
    
    GPSPayService *payService = [[GPSPayService alloc] initWithServiceId:_serviceId andSecret:_secret];
    
    GPSPaymentRequest *paymentRequest = [[GPSPaymentRequest alloc] init];
    
    paymentRequest.paymentType = (_testMode) ? @"spg_test" : @"spg";
    paymentRequest.cost = [NSString stringWithFormat:@"%@", sum];
    paymentRequest.name = orderName;
    paymentRequest.orderId = recurrentOrderId;
    paymentRequest.comment = comment;
    paymentRequest.background = @"1";
    
    // Recurrent payments init
    paymentRequest.reccurentParams = [GPSReccurentParams nextWithOrderId: recurrentOrderId];
    
    [payService paymentInit:paymentRequest successBlock:^(GPSPaymentResponse *paymentResponse) {
        NSLog(@"Reccurent paymentResponse: %@", paymentResponse);
        if(!paymentResponse.hasErrors) {
            success();
        } else {
            // Payment error
            if (fail != nil)
            {
                NSDictionary *errorDict = @{
                                            NSLocalizedDescriptionKey: FS_ERROR_TITLE,
                                            NSLocalizedFailureReasonErrorKey: (paymentResponse.message == nil) ? FS_EROR_UNKNOWN_ERROR : paymentResponse.message
                                            };
                NSError *error = [[NSError alloc] initWithDomain:FS_RFI_API_ERROR_DOMAIN code:100 userInfo:errorDict];
                fail(error);
            }
        }
    } failure:^(NSDictionary *error) {
        // error handling
        NSDictionary *errorDict = @{
                                    NSLocalizedDescriptionKey: FS_ERROR_TITLE,
                                    NSLocalizedFailureReasonErrorKey: [[error objectForKey: @"Error"] valueForKey: @"message"]
                                    };
        NSError *errorReturn = [[NSError alloc] initWithDomain:FS_GPS_API_ERROR_DOMAIN code:300 userInfo:errorDict];
        fail(errorReturn);
    }];
    
}

- (void) makePaymentWithCard: (FSCreditCard *) card orderId:(id) orderId orderName: (NSString *) orderName comment: (NSString *) comment andSum: (NSNumber *) sum
             successCallback: (void (^)()) success secureCallback: (void (^)(NSString *htmlFormData)) secure failCallback: (void (^)(NSError *error)) fail
{
    // Initing payment service v2
    GPSPayService *payService = [[GPSPayService alloc] initWithServiceId:_serviceId andSecret:_secret];
    
    // Biulding request to get card token
    GPSCardTokenRequest *cardTokenRequest = [[GPSCardTokenRequest alloc] initWithServiceId:_serviceId
                                                                                   andCard:card.PAN
                                                                               andExpMonth:card.expirityMonth
                                                                                andExpYear:card.expirityYear
                                                                                    andCvc:card.CVC
                                                                             andCardHolder:card.cardholder];
    // Sending request to get card token
    [payService createCardToken:cardTokenRequest isTest:YES successBlock:^(GPSCardTokenResponse *cardTokenResponse) {
        
        if(!cardTokenResponse.hasErrors) {
            
            NSString *cardToken = cardTokenResponse.token;
            
            // In case of success building payment request
            GPSPaymentRequest *paymentRequest = [[GPSPaymentRequest alloc] init];
            
            paymentRequest.paymentType = (_testMode) ? @"spg_test" : @"spg";
            paymentRequest.cost = [NSString stringWithFormat:@"%@", sum];
            paymentRequest.orderId = [NSString stringWithFormat:@"%@", orderId];
            paymentRequest.name = orderName;
            paymentRequest.comment = comment;
            paymentRequest.background = @"1"; // Shows that payment goes in background mode
            paymentRequest.cardToken = cardToken;
            
            paymentRequest.email = @"test@mail.ru"; // Required for recurrent payments
            
            // Initing recurrent payment
            NSString *url = @"http://url.test.ru";
            NSString *comment = @"<Description of recurrent payment purpose>";
            GPSReccurentParams * reccurentParams = [GPSReccurentParams firstWithUrl:url andComment:comment];
            reccurentParams.orderId = [NSString stringWithFormat:@"%@", orderId];
            paymentRequest.reccurentParams = reccurentParams;
            
            // Sending payment request
            // There are three possible outcomes:
            // - Successful payment
            // - Payment error
            // - Payment error due to 3-D secure authorization is needed first
            
//              GPSPaymentResponse *paymentResponse = (GPSPaymentResponse *) [payService paymentInit:paymentRequest];
            [payService paymentInit:paymentRequest successBlock:^(GPSPaymentResponse *paymentResponse) {
                
                // Saving SessionKey for getting transaction status further
                self.sessionKey = paymentResponse.sessionKey;

                if(!paymentResponse.hasErrors) {
                    
                    _lastTransactionId = paymentResponse.transactionId;
                    
                    // If card3ds object is present, 3-D secure authorization is needed
                    if(paymentResponse.card3ds) {
                        
                        NSString *termURL = [self termURLForTransactionId:paymentResponse.transactionId];
                        
                        // The easiest way to send POST request with required data to the card issuer is
                        // to use standard form with autosubmit and return it into the web-view
                        
                        NSString *rawFormDataPath = [[NSBundle mainBundle] pathForResource:@"card_3ds_form" ofType:nil];
                        NSString *rawFormData = [NSString stringWithContentsOfFile:rawFormDataPath encoding:NSUTF8StringEncoding error:nil];
                        
                        rawFormData = [rawFormData stringByReplacingOccurrencesOfString:@"${ACSUrl}" withString:paymentResponse.card3ds.ACSUrl];
                        rawFormData = [rawFormData stringByReplacingOccurrencesOfString:@"${MD}" withString:paymentResponse.card3ds.MD];
                        rawFormData = [rawFormData stringByReplacingOccurrencesOfString:@"${PaReq}" withString:paymentResponse.card3ds.PaReq];
                        rawFormData = [rawFormData stringByReplacingOccurrencesOfString:@"${TermUrl}" withString:termURL];
                        
                        // Making callbacks in the main queue
                        dispatch_async(dispatch_get_main_queue(), ^{
                            secure(rawFormData);
                        });
                    } else {
                        // Successful payment
                        // Making callbacks in the main queue
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success();
                        });
                    }
                } else {
                    // Payment error
                   
                        if (fail != nil)
                        {
                            NSDictionary *errorDict = @{
                                                        NSLocalizedDescriptionKey: FS_ERROR_TITLE,
                                                        NSLocalizedFailureReasonErrorKey: (paymentResponse.message == nil) ? FS_EROR_UNKNOWN_ERROR : paymentResponse.message
                                                        };
                            NSError *error = [[NSError alloc] initWithDomain:FS_GPS_API_ERROR_DOMAIN code:100 userInfo:errorDict];
                            fail(error);
                        }
                }
            } failure:^(NSDictionary *error) {
                // handling error
                NSDictionary *errorDict = @{
                                            NSLocalizedDescriptionKey: FS_ERROR_TITLE,
                                            NSLocalizedFailureReasonErrorKey: [[error objectForKey: @"Error"] valueForKey: @"message"]
                                            };
                NSError *errorReturn = [[NSError alloc] initWithDomain:FS_GPS_API_ERROR_DOMAIN code:300 userInfo:errorDict];
                fail(errorReturn);
            }];
        }else{
            // Error during get card token attempt
            if (fail != nil)
            {
                NSDictionary *errorDict = @{
                                            NSLocalizedDescriptionKey: FS_ERROR_TITLE,
                                            NSLocalizedFailureReasonErrorKey: (cardTokenResponse.message == nil) ? FS_EROR_UNKNOWN_ERROR : cardTokenResponse.message
                                            };
                NSError *error = [[NSError alloc] initWithDomain:FS_GPS_API_ERROR_DOMAIN code:200 userInfo:errorDict];
                fail(error);
            }
        }
    } failure:^(NSDictionary *error) {
        // handling error
        NSLog(@"Error - %@", error);
        NSDictionary *errorDict = @{
                                    NSLocalizedDescriptionKey: FS_EROR_UNKNOWN_ERROR,
                                    NSLocalizedFailureReasonErrorKey: @"Error occurred while sending request to bank. Check your internet connection." //[error valueForKey: @"message"]
                                    };
        NSError *errorResponse = [[NSError alloc] initWithDomain:FS_GPS_API_ERROR_DOMAIN code:200 userInfo:errorDict];
        fail(errorResponse);
    }];
  
}

// TO DO make tests
- (void) getLastTransactionStatus: (void (^)(FSOnlinePaymentStatus status)) callback
{
    NSLog(@"Transaction ID is %@", _lastTransactionId);
    if (_lastTransactionId == nil)
    {
        callback(FSOnlinePaymentStatusFailed);
    }
}

- (NSString *) termURL
{
    return [self termURLForTransactionId:_lastTransactionId];
}

- (NSString *) sessionKey
{
    return _sessionKey;
}

#pragma mark - Helpers

- (NSString *) termURLForTransactionId: (NSString *) transactionId
{
    // Using standard TermURL from bank that finishes transaction automatically
    // so we there's no need to handle with sending POST request to card issuer after 3DS authorization
    if (_testMode)
    {
        return [NSString stringWithFormat:@"https://test.paymentnepal.com/acquire?sid=%@&oid=%@&op=pay", _serviceId, transactionId];
    }
    return [NSString stringWithFormat:@"https://secure.paymentnepal.com/acquire?sid=%@&oid=%@&op=pay", _serviceId, transactionId];
}

@end
