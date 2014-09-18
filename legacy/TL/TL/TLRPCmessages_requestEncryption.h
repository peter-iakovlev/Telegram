#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;
@class TLEncryptedChat;

@interface TLRPCmessages_requestEncryption : TLMetaRpc

@property (nonatomic, retain) TLInputUser *user_id;
@property (nonatomic) int32_t random_id;
@property (nonatomic, retain) NSData *g_a;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_requestEncryption$messages_requestEncryption : TLRPCmessages_requestEncryption


@end

