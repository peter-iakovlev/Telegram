#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLWebPage;

@interface TLRPCmessages_getWebPage : TLMetaRpc

@property (nonatomic, retain) NSString *url;
@property (nonatomic) int32_t n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getWebPage$messages_getWebPage : TLRPCmessages_getWebPage


@end

