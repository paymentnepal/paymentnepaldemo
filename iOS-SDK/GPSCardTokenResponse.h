
#import <Foundation/Foundation.h>
#import "GPSCardTokenRequest.h"

@interface GPSCardTokenResponse : NSObject
{
    BOOL * _hasErrors;
    NSString * _errorDetails;
    NSString * _message;
    NSString * _status;
    NSString * _token;
    NSDictionary * _errors;
}

@property (nonatomic) BOOL * hasErrors;
@property (nonatomic, copy) NSString * errorDetails;
@property (nonatomic, copy) NSString * message;
@property (nonatomic, copy) NSString * status;
@property (nonatomic, copy) NSString * token;
@property (nonatomic, copy) NSDictionary * errors;

-(id) initWithRequest: (NSDictionary *)cardTokenRequest;

@end
