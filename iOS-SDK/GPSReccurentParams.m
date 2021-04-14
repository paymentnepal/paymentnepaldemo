
#import "GPSReccurentParams.h"

@implementation GPSReccurentParams

- (instancetype)initWithType:(GPSReccurentType)type
                     comment:(NSString *)comment
                         url:(NSString *)url
                     orderId:(NSString *)orderId
                  periodType:(GPSReccurentPeriodType)periodType
{
    self = [super init];
    if (self) {
        self.type = type;
        self.comment = comment;
        self.url = url;
        self.orderId = orderId;
        self.periodType = periodType;
    }
    
    return self;
}

- (NSString *)period
{
    switch (self.periodType) {
        case GPSReccurentPeriodTypeNone: return nil;
        case GPSReccurentPeriodTypeByRequest: return @"byrequest";
    }
}

+ (instancetype)firstWithUrl:(NSString *)url andComment:(NSString *)comment
{
    return [[GPSReccurentParams alloc] initWithType:GPSReccurentTypeFirst
                                            comment:comment
                                                url:url
                                            orderId:nil
                                         periodType:GPSReccurentPeriodTypeByRequest];
}

+ (instancetype)nextWithOrderId:(NSString *)orderId
{
    return [[GPSReccurentParams alloc] initWithType:GPSReccurentTypeNext
                                            comment:nil
                                                url:nil
                                            orderId:orderId
                                         periodType:GPSReccurentPeriodTypeNone];
}

@end
