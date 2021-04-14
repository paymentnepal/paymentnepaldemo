
#import <Foundation/Foundation.h>

typedef void(^successBlock)(NSDictionary *result);
typedef void(^errorBlock)(NSDictionary *error);

@interface GPSRestRequester : NSObject

+ (void)request:(NSString *)url
      andMethod:(NSString *)method
      andParams:(NSDictionary *)requestParams
      andSecret:(NSString *)secret
   successBlock:(successBlock)success
        failure:(errorBlock)failure;

@end
