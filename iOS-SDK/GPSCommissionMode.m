
#import "GPSCommissionMode.h"

static NSString * const PARTNER = @"partner";
static NSString * const ABONENT = @"abonent";

@implementation GPSCommissionMode

-(NSString *) commissionPartner {
    return PARTNER;
}
-(NSString *) commissionAbonent {
    return ABONENT;
}

@end
