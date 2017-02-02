#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;
@class TLmessages_Chats;

@interface TLRPCmessages_getCommonChats : TLMetaRpc

@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic) int32_t max_id;
@property (nonatomic) int32_t limit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_getCommonChats$messages_getCommonChats : TLRPCmessages_getCommonChats


@end

