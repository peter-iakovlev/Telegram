#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLCdnConfig;

@interface TLRPChelp_getCdnConfig : TLMetaRpc


- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPChelp_getCdnConfig$help_getCdnConfig : TLRPChelp_getCdnConfig


@end

