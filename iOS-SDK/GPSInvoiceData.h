
#import <Foundation/Foundation.h>

@interface GPSInvoiceItem : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *unit;
@property (nonatomic, copy) NSString *vatMode;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *quantity;
@property (nonatomic, strong) NSNumber *sum;
@property (nonatomic, strong) NSNumber *vatAmount;
@property (nonatomic, strong) NSNumber *discountRate;
@property (nonatomic, strong) NSNumber *discountAmount;

@end

@interface GPSInvoiceData : NSObject

@property (nonatomic, strong) NSNumber *vatTotal;
@property (nonatomic, strong) NSNumber *discountTotal;
@property (nonatomic, strong) NSArray<GPSInvoiceItem *> *items;

+ (instancetype)invoiceDataWithVatTotal:(NSNumber *)vatTotal
                          discountTotal:(NSNumber *)discountTotal
                           invoiceItems:(NSArray<GPSInvoiceItem *> *)items;

- (NSString *)parameters;

@end
