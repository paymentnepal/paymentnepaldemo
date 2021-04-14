
#import <Foundation/Foundation.h>
#import "GPSPaymentRequest.h"
#import "GPSCardThreeDs.h"

@interface GPSPaymentResponse : NSObject
{
    BOOL * _hasErrors;
    NSString * _transactionId;
    NSString * _terminalCode;
    NSString * _sessionKey;
    NSString * _help;
    NSString * _status;
    NSString * _message;
    NSString * _errors;
    GPSCardThreeDs * _card3ds;
}

- (id)initWithRequest:(NSDictionary *)paymentRequest;

@property (nonatomic, copy) NSString * transactionId;
@property (nonatomic, copy) NSString * terminalCode;
@property (nonatomic, copy) NSString * sessionKey;
@property (nonatomic, copy) NSString * help;
@property (nonatomic, copy) NSString * status;
@property (nonatomic, copy) NSString * message;
@property (nonatomic, copy) NSString * errors;
@property (nonatomic) BOOL * hasErrors;
@property (nonatomic, copy) GPSCardThreeDs * card3ds;


@end
