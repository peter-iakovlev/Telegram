#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLScheme;

@interface TLRPChelp_getScheme : TLMetaRpc

@property (nonatomic) int32_t version;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPChelp_getScheme$help_getScheme : TLRPChelp_getScheme


@end

