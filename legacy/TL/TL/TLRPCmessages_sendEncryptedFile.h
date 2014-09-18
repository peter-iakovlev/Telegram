#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputEncryptedChat;
@class TLInputEncryptedFile;
@class TLmessages_SentEncryptedMessage;

@interface TLRPCmessages_sendEncryptedFile : TLMetaRpc

@property (nonatomic, retain) TLInputEncryptedChat *peer;
@property (nonatomic) int64_t random_id;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) TLInputEncryptedFile *file;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCmessages_sendEncryptedFile$messages_sendEncryptedFile : TLRPCmessages_sendEncryptedFile


@end

