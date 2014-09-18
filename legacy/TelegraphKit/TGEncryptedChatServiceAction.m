#import "TGEncryptedChatServiceAction.h"

@implementation TGEncryptedChatServiceAction

- (id)initWithEncryptedConversationId:(int64_t)encryptedConversationId messageRandomId:(int64_t)messageRandomId action:(int32_t)action actionContext:(int64_t)actionContext
{
    self = [super initWithType:TGEncryptedChatServiceActionType];
    if (self != nil)
    {
        int64_t uniqueId = 0;
        arc4random_buf(&uniqueId, 8);
        self.uniqueId = uniqueId;
        
        _encryptedConversationId = encryptedConversationId;
        _action = action;
        _messageRandomId = messageRandomId;
        _actionContext = actionContext;
    }
    return self;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&_encryptedConversationId length:8];
    [data appendBytes:&_messageRandomId length:8];
    [data appendBytes:&_action length:4];
    [data appendBytes:&_actionContext length:8];
    return data;
}

- (TGFutureAction *)deserialize:(NSData *)data
{
    int64_t encryptedConversationId = 0;
    [data getBytes:&encryptedConversationId range:NSMakeRange(0, 8)];
    
    int64_t messageRandomId = 0;
    [data getBytes:&messageRandomId range:NSMakeRange(8, 8)];
    
    int32_t action = 0;
    [data getBytes:&action range:NSMakeRange(16, 4)];
    
    int64_t actionContext = 0;
    [data getBytes:&actionContext range:NSMakeRange(20, 8)];
    
    return [[TGEncryptedChatServiceAction alloc] initWithEncryptedConversationId:encryptedConversationId messageRandomId:messageRandomId action:action actionContext:actionContext];
}

@end
