
#import "FSCreditCard.h"

@implementation FSCreditCard

+ (instancetype) cardWithPAN: (NSString *) PAN
               expirityMonth: (NSString *) expirityMonth
                expirityYear: (NSString *) expirityYear
                         CVC: (NSString *) CVC
               andCardholder: (NSString *) cardholder
{
    
    return [[FSCreditCard alloc] initWithPAN:PAN expirityMonth:expirityMonth expirityYear:expirityYear CVC:CVC andCardholder:cardholder];
    
}

- (instancetype) initWithPAN: (NSString *) PAN
                   expirityMonth: (NSString *) expirityMonth
                    expirityYear: (NSString *) expirityYear
                             CVC: (NSString *) CVC
                   andCardholder: (NSString *) cardholder
{
    
    self = [super init];
    
    _PAN = PAN;
    _expirityMonth = expirityMonth;
    _expirityYear = expirityYear;
    _CVC = CVC;
    _cardholder = cardholder;
    
    return self;
    
}

@end
