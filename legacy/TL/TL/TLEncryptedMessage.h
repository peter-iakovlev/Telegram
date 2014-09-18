#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLEncryptedFile;

@interface TLEncryptedMessage : NSObject <TLObject>

@property (nonatomic) int64_t random_id;
@property (nonatomic) int32_t chat_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSData *bytes;

@end

@interface TLEncryptedMessage$encryptedMessage : TLEncryptedMessage

@property (nonatomic, retain) TLEncryptedFile *file;

@end

@interface TLEncryptedMessage$encryptedMessageService : TLEncryptedMessage


@end

