
#import "GPSCardThreeDs.h"

@implementation GPSCardThreeDs

-(id) initWithParams: (NSDictionary *)params {
    
    if(self = [super init]) {
        _ACSUrl = [params objectForKey:@"ACSUrl"];
        _MD = [params objectForKey:@"MD"];
        _PaReq = [params objectForKey:@"PaReq"];
    }
    
    return self;
}
@end
