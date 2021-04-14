
#import <Foundation/Foundation.h>

@interface GPSHelpers : NSObject

@end

@interface NSString (GPSHelpers)
- (NSString *) md5;
@end

@interface NSData (GPSHelpers)
- (NSString*)md5;
@end


