#import "TGUpdatePeerLayerFutureAction.h"

@implementation TGUpdatePeerLayerFutureAction

- (id)initWithEncryptedConversationId:(int64_t)encryptedConversationId messageRandomId:(int64_t)messageRandomId
{
    self = [super initWithType:TGUpdatePeerLayerFutureActionType];
    if (self != nil)
    {
        self.uniqueId = encryptedConversationId;
        
        _messageRandomId = messageRandomId;
    }
    return self;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    uint8_t version = 1;
    [data appendBytes:&version length:1];
    
    int64_t randomId = _messageRandomId;
    [data appendBytes:&randomId length:8];
    
    return data;
}

- (TGFutureAction *)deserialize:(NSData *)data
{
    uint8_t version = 0;
    [data getBytes:&version range:NSMakeRange(0, 1)];
    
    int64_t randomId = 0;
    [data getBytes:&randomId range:NSMakeRange(1, 8)];
    
    TGUpdatePeerLayerFutureAction *action = [[TGUpdatePeerLayerFutureAction alloc] initWithEncryptedConversationId:0 messageRandomId:randomId];
    
    return action;
}

@end
