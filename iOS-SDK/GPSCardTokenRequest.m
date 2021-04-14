
#import "GPSCardTokenRequest.h"

@implementation GPSCardTokenRequest

- (id)initWithServiceId: (NSString *)serviceId andCard: (NSString *)card andExpMonth: (NSString *)expMonth andExpYear: (NSString *)expYear andCvc: (NSString *)cvc andCardHolder: (NSString *)cardHolder {
    
    if(self = [super init]) {
        _serviceId = serviceId;
        _card = card;
        
        if([_expMonth length] == 1) {
            _expMonth = [@"0" stringByAppendingString: expYear];
        } else {
            _expMonth = expMonth;
        }
        
        _expYear = expYear;
        _cvc = cvc;
        
        if([cardHolder length] > 0)
            _cardHolder = cardHolder;
    }
    
    return self;
}

@end
