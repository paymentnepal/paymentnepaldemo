
#import "GPSRestRequester.h"
#import "GPSSigner.h"

@implementation GPSRestRequester

+ (void)request:(NSString *)url
      andMethod:(NSString *)method
      andParams:(NSDictionary *)requestParams
      andSecret:(NSString *)secret
   successBlock:(successBlock)success
        failure:(errorBlock)failure {
    
    NSString * urlAsString = url;
    
    NSString * urlParametrs = @"";
    
    NSURL *urlLink = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:urlLink ];
    
    [urlRequest setCachePolicy: NSURLRequestReloadIgnoringCacheData];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:method];
    [urlRequest setValue:@"UTF-8" forHTTPHeaderField:@"content-charset"];
    
    // sort request params
    for (id key in requestParams) {
        id object = [requestParams objectForKey:key];
        
        if([urlParametrs length] > 0) {
            urlParametrs = [urlParametrs stringByAppendingString: @"&"];
        }
        
        NSString * escapedString = [object stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        
        escapedString = [GPSSigner escapeString:escapedString];
        
        urlParametrs = [urlParametrs stringByAppendingFormat: @"%@=%@", key, escapedString];
    }
    
    if (secret) {
        // Create electronic sign for request
        NSString * check = [GPSSigner sign :method url:urlAsString requestParams:requestParams secretKey:secret];
        
        urlParametrs = [urlParametrs stringByAppendingFormat:@"&check=%@", check];
    }
    
    // GET request
    if ([[method uppercaseString] isEqualToString: @"GET"]) {
        urlParametrs = [@"?" stringByAppendingString: urlParametrs];
    } else {
        // Add POST to request
        [urlRequest setHTTPBody:[urlParametrs dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                NSDictionary * errorDictionary = @{@"status": @"error", @"message" : [NSString stringWithFormat: @"HTTP error occured = %@", error]};
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(errorDictionary);
                });
            }
            return;
        }
        
        if (!data.length) {
            if (failure) {
                NSDictionary * errorDictionary = @{@"status": @"error", @"message" : @"Empty HTTP response."};
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(errorDictionary);
                });
            }
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary * jsonData = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &jsonError];
        
        if (!jsonData) {
            if (failure) {
                NSDictionary * errorDictionary = @{@"status": @"error", @"message" : [NSString stringWithFormat:@"Error parsing JSON: %@", jsonError]};
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(errorDictionary);
                });
            }
        } else {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(jsonData);
                });
            }
        }
    }];
    
    [task resume];
}

@end
