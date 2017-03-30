#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInvoice : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *currency;
@property (nonatomic, retain) NSArray *prices;

@end

@interface TLInvoice$invoiceMeta : TLInvoice


@end

