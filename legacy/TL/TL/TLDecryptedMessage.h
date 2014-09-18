#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLDecryptedMessageMedia;
@class TLDecryptedMessageAction;

@interface TLDecryptedMessage : NSObject <TLObject>

@property (nonatomic) int64_t random_id;
@property (nonatomic, retain) NSData *random_bytes;

@end

@interface TLDecryptedMessage$decryptedMessage : TLDecryptedMessage

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) TLDecryptedMessageMedia *media;

@end

@interface TLDecryptedMessage$decryptedMessageService : TLDecryptedMessage

@property (nonatomic, retain) TLDecryptedMessageAction *action;

@end

