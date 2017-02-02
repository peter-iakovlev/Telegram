#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLcontacts_TopPeers;

@interface TLRPCcontacts_getTopPeers : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t limit;
@property (nonatomic) int32_t n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCcontacts_getTopPeers$contacts_getTopPeers : TLRPCcontacts_getTopPeers


@end

