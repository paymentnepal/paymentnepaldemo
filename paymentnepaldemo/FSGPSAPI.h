
#import <Foundation/Foundation.h>

#import "FSCreditCard.h"

// Two states available: payed, error
typedef enum : NSUInteger {
    FSOnlinePaymentStatusSuccess,
    FSOnlinePaymentStatusFailed
} FSOnlinePaymentStatus;

#define FS_GPS_API_ERROR_DOMAIN @"FS_GPS_API"

@interface FSGPSAPI : NSObject
    
- (id) initWithServideId: (id) serviceId key: (NSString *) key andTestMode: (BOOL) testMode;
- (id) initWithServideId: (id) serviceId secret: (NSString *) secret andTestMode: (BOOL) testMode;

- (void) makePaymentWithCard: (FSCreditCard *) card orderId:(id) orderId orderName: (NSString *) orderName comment: (NSString *) comment andSum: (NSNumber *) sum
             successCallback: (void (^)()) success secureCallback: (void (^)(NSString *htmlFormData)) secure failCallback: (void (^)(NSError *error)) fail;

- (void) makeReccurentPayment: (NSString *) orderId orderName: (NSString *) orderName comment: (NSString *) comment andSum: (NSNumber *) sum
              successCallback: (void (^)()) success failCallback: (void (^)(NSError *error)) fail;

- (void) getLastTransactionStatus: (void (^)(FSOnlinePaymentStatus status)) callback;

- (NSString *) termURL;
- (NSString *) sessionKey;

@end
