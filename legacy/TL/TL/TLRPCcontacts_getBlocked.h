#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLcontacts_Blocked;

@interface TLRPCcontacts_getBlocked : TLMetaRpc

@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCcontacts_getBlocked$contacts_getBlocked : TLRPCcontacts_getBlocked


@end

