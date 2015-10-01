#import "TGSynchronizeEncryptedChatSettingsFutureAction.h"

@implementation TGSynchronizeEncryptedChatSettingsFutureAction

- (id)initWithEncryptedConversationId:(int64_t)encryptedConversationId messageLifetime:(int)messageLifetime messageRandomId:(int64_t)messageRandomId
{
    self = [super initWithType:TGSynchronizeEncryptedChatSettingsFutureActionType];
    if (self != nil)
    {
        self.uniqueId = encryptedConversationId;
        
        _messageLifetime = messageLifetime;
        _messageRandomId = messageRandomId;
    }
    return self;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:1 + 4];
    
    uint8_t version = 1;
    [data appendBytes:&version length:1];
    
    int32_t lifetime = _messageLifetime;
    [data appendBytes:&lifetime length:4];
    
    int64_t randomId = _messageRandomId;
    [data appendBytes:&randomId length:8];
    
    return data;
}

- (TGFutureAction *)deserialize:(NSData *)data
{
    uint8_t version = 0;
    [data getBytes:&version range:NSMakeRange(0, 1)];
    
    int32_t lifetime = 0;
    [data getBytes:&lifetime range:NSMakeRange(1, 4)];
    
    int64_t randomId = 0;
    [data getBytes:&randomId range:NSMakeRange(5, 8)];
    
    TGSynchronizeEncryptedChatSettingsFutureAction *action = [[TGSynchronizeEncryptedChatSettingsFutureAction alloc] initWithEncryptedConversationId:0 messageLifetime:lifetime messageRandomId:randomId];
    
    return action;
}

@end
