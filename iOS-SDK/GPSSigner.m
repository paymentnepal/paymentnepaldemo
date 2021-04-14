
#import "GPSSigner.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation GPSSigner

+ (NSString *) escapeString: (NSString *) escString {
    
    //In case of JSON variable inside the string need to quote special symbols
    escString = [escString stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    escString = [escString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    escString = [escString stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    escString = [escString stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    escString = [escString stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
    
    return escString;
}

+ (NSString *) sign: (NSString *)method url: (NSString *)url requestParams: (NSDictionary *)requestParams secretKey: (NSString *) secretKey {
    
    // Sort dict by key
    NSArray * sortedKeysArray = [[requestParams allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];

    NSString * urlParametrs = @"";

    NSURL * uri = [NSURL URLWithString:url];
      
    for (id key in sortedKeysArray) {
        id object = [requestParams objectForKey:key];
        
        if([urlParametrs length] > 0) {
            urlParametrs = [urlParametrs stringByAppendingString: @"&"];
        }
        
        // HTML Encoding  (iOS7 and above)
        NSString * escapedString = [object stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        
        escapedString = [self escapeString:escapedString];
        
        urlParametrs = [urlParametrs stringByAppendingFormat: @"%@=%@", key, escapedString];
    }
    

    // Get string to hash
    NSString * data = [method uppercaseString];
    data = [data stringByAppendingFormat: @"%@%@%@%@%@%@", @"\n", [uri host], @"\n", [uri path], @"\n", urlParametrs];
    
    // hmac 256
    const char *cKey = [secretKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    //base64 encoding
    NSString *base64String = [hash base64EncodedStringWithOptions:0];
    
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    
    return base64String;
    
}



@end
