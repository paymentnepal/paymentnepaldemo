
#import <Foundation/Foundation.h>

@interface GPSSigner : NSObject

+ (NSString *) sign: (NSString *)method url: (NSString *)url requestParams: (NSDictionary *)requestParams secretKey: (NSString *) secretKey;

+ (NSString *) escapeString: (NSString *) escString;

@end
