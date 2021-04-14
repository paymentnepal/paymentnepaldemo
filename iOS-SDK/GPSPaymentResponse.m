
#import "GPSPaymentResponse.h"

@implementation GPSPaymentResponse

- (id)initWithRequest:(NSDictionary *)paymentRequest {
    self = [super init];
    
    if (self) {

        _status = [paymentRequest objectForKey:@"status"];
        
        //in case of error
        if ([_status isEqualToString:@"error"]) {
            _hasErrors = (BOOL *) YES;
            _message = [paymentRequest objectForKey:@"message"];
            _errors = [paymentRequest objectForKey:@"errors"];
        }
        
        //in case of success
        if ([_status isEqualToString:@"success"]) {
            
            if([paymentRequest objectForKey:@"3ds"]) {

                GPSCardThreeDs * threeDS = [[GPSCardThreeDs alloc] initWithParams: [paymentRequest objectForKey:@"3ds"]];
                
                _card3ds = threeDS;
            }

            _help = [paymentRequest objectForKey:@"help"];
            _transactionId = [paymentRequest objectForKey:@"tid"];
        }

        self.sessionKey = paymentRequest[@"session_key"];
    }
    
    return self;
}

@end
