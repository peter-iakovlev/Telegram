#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLSendMessageAction;

@interface TLRPCmessages_setTyping : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic, retain) TLSendMessageAction *action;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_setTyping$messages_setTyping : TLRPCmessages_setTyping


@end

