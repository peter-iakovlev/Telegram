#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLgeochats_Messages;

@interface TLRPCgeochats_getRecents : TLMetaRpc

@property (nonatomic) int32_t offset;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCgeochats_getRecents$geochats_getRecents : TLRPCgeochats_getRecents


@end

