#import "TL/TLInvoice.h"

@interface TLInvoice$invoice : TLInvoice$invoiceMeta

@property (nonatomic, readonly) bool test;
@property (nonatomic, readonly) bool name_requested;
@property (nonatomic, readonly) bool phone_requested;
@property (nonatomic, readonly) bool email_requested;
@property (nonatomic, readonly) bool shipping_address_requested;
@property (nonatomic, readonly) bool flexible;

@end
