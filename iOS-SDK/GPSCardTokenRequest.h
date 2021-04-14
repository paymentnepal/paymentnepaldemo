
#import <Foundation/Foundation.h>

@interface GPSCardTokenRequest : NSObject
{
    NSString * _serviceId;
    NSString * _card;
    NSString *_expMonth;
    NSString *_expYear;
    NSString *_cvc;
    NSString *_cardHolder;
}

@property (nonatomic, copy) NSString * serviceId;
@property (nonatomic, copy) NSString * card;
@property (nonatomic, copy) NSString * expMonth;
@property (nonatomic, copy) NSString * expYear;
@property (nonatomic, copy) NSString * cvc;
@property (nonatomic, copy) NSString * cardHolder;

- (id)initWithServiceId: (NSString *)serviceId andCard: (NSString *)card andExpMonth: (NSString *)expMonth andExpYear: (NSString *)expYear andCvc: (NSString *)cvc andCardHolder: (NSString *)cardHolder;


@end
