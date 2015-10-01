#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputEncryptedChat;

@interface TLRPCmessages_readEncryptedHistory : TLMetaRpc

@property (nonatomic, retain) TLInputEncryptedChat *peer;
@property (nonatomic) int32_t max_date;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_readEncryptedHistory$messages_readEncryptedHistory : TLRPCmessages_readEncryptedHistory


@end

