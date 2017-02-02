#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCmessages_reorderPinnedDialogs : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSArray *order;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_reorderPinnedDialogs$messages_reorderPinnedDialogs : TLRPCmessages_reorderPinnedDialogs


@end

