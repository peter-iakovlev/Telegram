#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLDecryptedMessageAction : NSObject <TLObject>


@end

@interface TLDecryptedMessageAction$decryptedMessageActionSetMessageTTL : TLDecryptedMessageAction

@property (nonatomic) int32_t ttl_seconds;

@end

@interface TLDecryptedMessageAction$decryptedMessageActionViewMessage : TLDecryptedMessageAction

@property (nonatomic) int64_t random_id;

@end

@interface TLDecryptedMessageAction$decryptedMessageActionScreenshotMessage : TLDecryptedMessageAction

@property (nonatomic) int64_t random_id;

@end

@interface TLDecryptedMessageAction$decryptedMessageActionScreenshot : TLDecryptedMessageAction


@end

@interface TLDecryptedMessageAction$decryptedMessageActionDeleteMessages : TLDecryptedMessageAction

@property (nonatomic, retain) NSArray *random_ids;

@end

@interface TLDecryptedMessageAction$decryptedMessageActionFlushHistory : TLDecryptedMessageAction


@end

