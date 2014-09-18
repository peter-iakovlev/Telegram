#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLcontacts_Found;

@interface TLRPCcontacts_search : TLMetaRpc

@property (nonatomic, retain) NSString *q;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCcontacts_search$contacts_search : TLRPCcontacts_search


@end

