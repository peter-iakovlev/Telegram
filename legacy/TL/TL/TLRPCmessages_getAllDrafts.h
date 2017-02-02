#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUpdates;

@interface TLRPCmessages_getAllDrafts : TLMetaRpc


- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getAllDrafts$messages_getAllDrafts : TLRPCmessages_getAllDrafts


@end

