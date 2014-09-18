#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_ChatFull;

@interface TLRPCmessages_getFullChat : TLMetaRpc

@property (nonatomic) int32_t chat_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getFullChat$messages_getFullChat : TLRPCmessages_getFullChat


@end

