#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;

@interface TLRPCmessages_editChatAdmin : TLMetaRpc

@property (nonatomic) int32_t chat_id;
@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic) bool is_admin;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_editChatAdmin$messages_editChatAdmin : TLRPCmessages_editChatAdmin


@end

