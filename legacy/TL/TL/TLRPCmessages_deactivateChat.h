#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUpdates;

@interface TLRPCmessages_deactivateChat : TLMetaRpc

@property (nonatomic) int32_t chat_id;
@property (nonatomic) bool enabled;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_deactivateChat$messages_deactivateChat : TLRPCmessages_deactivateChat


@end

