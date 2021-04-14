
#import <Foundation/Foundation.h>

@interface GPSTransactionDetails : NSObject
{
    NSString * _status;
    NSString * _transactionId;
    NSString * _message;
    NSString * _help;
    NSString * _incomeTotal;
    NSString * _partnerIncome;
    NSString * _orderId;
    NSString * _serviceName;
    NSString * _serviceId;
    NSString * _transactionStatus;
    

    
}

@property (nonatomic, copy) NSString * status;
@property (nonatomic, copy) NSString * transactionId;
@property (nonatomic, copy) NSString * message;
@property (nonatomic, copy) NSString * help;
@property (nonatomic, copy) NSString * incomeTotal;
@property (nonatomic, copy) NSString * partnerIncome;
@property (nonatomic, copy) NSString * orderId;
@property (nonatomic, copy) NSString * serviceName;
@property (nonatomic, copy) NSString * serviceId;
@property (nonatomic, copy) NSString * transactionStatus;


-(id)initWithReponse: (NSDictionary *)response;

@end
