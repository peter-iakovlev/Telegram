#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;

@interface TLRPCmessages_setTyping : TLMetaRpc

@property (nonatomic, retain) TLInputPeer *peer;
@property (nonatomic) bool typing;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_setTyping$messages_setTyping : TLRPCmessages_setTyping


@end

