#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLEncryptedFile;

@interface TLmessages_SentEncryptedMessage : NSObject <TLObject>

@property (nonatomic) int32_t date;

@end

@interface TLmessages_SentEncryptedMessage$messages_sentEncryptedMessage : TLmessages_SentEncryptedMessage


@end

@interface TLmessages_SentEncryptedMessage$messages_sentEncryptedFile : TLmessages_SentEncryptedMessage

@property (nonatomic, retain) TLEncryptedFile *file;

@end

