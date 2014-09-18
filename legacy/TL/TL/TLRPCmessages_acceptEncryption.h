#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputEncryptedChat;
@class TLEncryptedChat;

@interface TLRPCmessages_acceptEncryption : TLMetaRpc

@property (nonatomic, retain) TLInputEncryptedChat *peer;
@property (nonatomic, retain) NSData *g_b;
@property (nonatomic) int64_t key_fingerprint;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_acceptEncryption$messages_acceptEncryption : TLRPCmessages_acceptEncryption


@end

