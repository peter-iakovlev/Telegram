#import "TLMessage$modernMessageService.h"

#import "TLMetaClassStore.h"

//messageService flags:# out:flags.1?true mentioned:flags.4?true media_unread:flags.5?true silent:flags.13?true post:flags.14?true id:int from_id:flags.8?int to_id:Peer date:int action:MessageAction = Message;

@implementation TLMessage$modernMessageService

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLMessage$modernMessageService serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLMessage$modernMessageService *result = [[TLMessage$modernMessageService alloc] init];
    
    int32_t flags = [is readInt32];
    
    result.flags = flags;
    result.n_id = [is readInt32];
    
    if (flags & (1 << 8))
    {
        result.from_id = [is readInt32];
    }
    
    int32_t peerSignature = [is readInt32];
    result.to_id = TLMetaClassStore::constructObject(is, peerSignature, environment, nil, error);
    if (error != nil && *error != nil) {
        return nil;
    }
    
    if (flags & (1 << 3)) {
        result.reply_to_msg_id = [is readInt32];
    }
    
    result.date = [is readInt32];
    
    int32_t actionSignature = [is readInt32];
    result.action = TLMetaClassStore::constructObject(is, actionSignature, environment, nil, error);
    if (error != nil && *error != nil) {
        return nil;
    }
    
    return result;
}


@end
