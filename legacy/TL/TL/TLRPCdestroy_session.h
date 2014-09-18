#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLDestroySessionRes;

@interface TLRPCdestroy_session : TLMetaRpc

@property (nonatomic) int64_t session_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCdestroy_session$destroy_session : TLRPCdestroy_session


@end

