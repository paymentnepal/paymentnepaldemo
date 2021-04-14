
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GPSReccurentType) {
    GPSReccurentTypeFirst = 0,
    GPSReccurentTypeNext
};

typedef NS_ENUM(NSUInteger, GPSReccurentPeriodType) {
    GPSReccurentPeriodTypeNone = 0,
    GPSReccurentPeriodTypeByRequest
};

@interface GPSReccurentParams : NSObject

@property (nonatomic) GPSReccurentType type;
@property (nonatomic) GPSReccurentPeriodType periodType;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy, readonly) NSString *period;

+ (instancetype)firstWithUrl:(NSString *)url andComment:(NSString *)comment;
+ (instancetype)nextWithOrderId:(NSString *)orderId;

@end
