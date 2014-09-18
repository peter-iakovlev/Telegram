#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputEncryptedChat;

@interface TLRPCmessages_setEncryptedTyping : TLMetaRpc

@property (nonatomic, retain) TLInputEncryptedChat *peer;
@property (nonatomic) bool typing;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_setEncryptedTyping$messages_setEncryptedTyping : TLRPCmessages_setEncryptedTyping


@end

