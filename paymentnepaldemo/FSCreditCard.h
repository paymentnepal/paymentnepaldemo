
#import <Foundation/Foundation.h>

@interface FSCreditCard : NSObject

@property (nonatomic, strong, readonly) NSString *PAN;
@property (nonatomic, strong, readonly) NSString *expirityMonth;
@property (nonatomic, strong, readonly) NSString *expirityYear;
@property (nonatomic, strong, readonly) NSString *CVC;
@property (nonatomic, strong, readonly) NSString *cardholder;

+ (instancetype) cardWithPAN: (NSString *) PAN
               expirityMonth: (NSString *) expirityMonth
                expirityYear: (NSString *) expirityYear
                         CVC: (NSString *) CVC
               andCardholder: (NSString *) cardholder;

@end
