
#import "GPSConnectionProfile.h"

static NSString * const baseUrl = @"https://pay.paymentnepal.com/alba/";
static NSString * const cardTokenUrl = @"https://secure.paymentnepal.com/cardtoken/";
// static NSString * const cardTokenTestUrl = @"https://secure.paymentnepal.com/cardtoken/";

@implementation GPSConnectionProfile

+ (NSString *)baseUrl {
    return baseUrl;
}

+ (NSString *)cardTokenUrl {
    return cardTokenUrl;
}

+ (NSString *)cardTokenTestUrl {
    return cardTokenTestUrl;
}

@end
