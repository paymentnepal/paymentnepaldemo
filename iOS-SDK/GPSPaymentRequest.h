
#import <Foundation/Foundation.h>

@class GPSReccurentParams;
@class GPSInvoiceData;

@interface GPSPaymentRequest : NSObject {
    NSString * _paymentType;
    NSMutableDictionary * params;
    
    NSString * _cost;
    NSString * _name;
    NSString * _email;
    NSString * _phone;
    NSString * _orderId;
    NSString * _key;
    NSString * _secret;
    NSString * _background;
    NSString * _comment;
    NSString * _cardToken;
    NSMutableArray * _customFields;
    NSString * _commissionMode;
    NSString * _test;
}

@property (nonatomic, copy) NSString * paymentType;
@property (nonatomic, copy) NSString * cost;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * email;
@property (nonatomic, copy) NSString * phone;
@property (nonatomic, copy) NSString * orderId;
@property (nonatomic, copy) NSString * key;
@property (nonatomic, copy) NSString * secret;
@property (nonatomic, copy) NSString * background;
@property (nonatomic, copy) NSString * comment;
@property (nonatomic, copy) NSString * cardToken;
@property (nonatomic, copy) NSMutableArray * customFields;
@property (nonatomic, copy) NSString * commissionMode;
@property (nonatomic, copy) NSString * test;

@property (nonatomic, strong) GPSReccurentParams *reccurentParams;
@property (nonatomic, strong) GPSInvoiceData *invoiceData;

@end
