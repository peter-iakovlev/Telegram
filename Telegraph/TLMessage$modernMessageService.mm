#import "TLMessage$modernMessageService.h"

#import "TLMetaClassStore.h"

//flags:# id:int from_id:flags.8?int to_id:Peer date:int action:MessageAction = Message;

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
    
    result.date = [is readInt32];
    
    int32_t actionSignature = [is readInt32];
    result.action = TLMetaClassStore::constructObject(is, actionSignature, environment, nil, error);
    
    return result;
}


@end
