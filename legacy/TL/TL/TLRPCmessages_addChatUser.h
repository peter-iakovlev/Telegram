#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;
@class TLUpdates;

@interface TLRPCmessages_addChatUser : TLMetaRpc

@property (nonatomic) int32_t chat_id;
@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic) int32_t fwd_limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_addChatUser$messages_addChatUser : TLRPCmessages_addChatUser


@end

