#import "TGAcceptEncryptionFutureAction.h"

@implementation TGAcceptEncryptionFutureAction

- (id)initWithEncryptedConversationId:(int64_t)encryptedConversationId
{
    self = [super initWithType:TGAcceptEncryptionFutureActionType];
    if (self != nil)
    {
        self.uniqueId = encryptedConversationId;
    }
    return self;
}

- (NSData *)serialize
{
    return [NSData data];
}

- (TGFutureAction *)deserialize:(NSData *)__unused data
{
    return [[TGAcceptEncryptionFutureAction alloc] initWithEncryptedConversationId:0];
}

@end
