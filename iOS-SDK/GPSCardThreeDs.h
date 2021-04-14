
#import <Foundation/Foundation.h>

@interface GPSCardThreeDs : NSObject
{
    NSString * _ACSUrl;
    NSString * _MD;
    NSString * _PaReq;
}

@property (nonatomic, copy) NSString * ACSUrl;
@property (nonatomic, copy) NSString * MD;
@property (nonatomic, copy) NSString * PaReq;

-(id) initWithParams: (NSDictionary *)params;

@end
