#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChatInvite;

@interface TLRPCmessages_checkChatInvite : TLMetaRpc

@property (nonatomic, retain) NSString *n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_checkChatInvite$messages_checkChatInvite : TLRPCmessages_checkChatInvite


@end

