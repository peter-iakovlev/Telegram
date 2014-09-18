#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLphone_DhConfig;

@interface TLRPCphone_getDhConfig : TLMetaRpc


- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCphone_getDhConfig$phone_getDhConfig : TLRPCphone_getDhConfig


@end

