#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_DhConfig;

@interface TLRPCmessages_getDhConfig : TLMetaRpc

@property (nonatomic) int32_t version;
@property (nonatomic) int32_t random_length;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getDhConfig$messages_getDhConfig : TLRPCmessages_getDhConfig


@end

