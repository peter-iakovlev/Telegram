#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputEncryptedChat;
@class TLmessages_SentEncryptedMessage;

@interface TLRPCmessages_sendEncrypted : TLMetaRpc

@property (nonatomic, retain) TLInputEncryptedChat *peer;
@property (nonatomic) int64_t random_id;
@property (nonatomic, retain) NSData *data;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_sendEncrypted$messages_sendEncrypted : TLRPCmessages_sendEncrypted


@end

