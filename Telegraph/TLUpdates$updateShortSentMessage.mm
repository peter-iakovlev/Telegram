#import "TLUpdates$updateShortSentMessage.h"
#import "TLMetaClassStore.h"

//updateShortSentMessage flags:# id:int pts:int pts_count:int date:int media:flags.9?MessageMedia entities:flags.7?Vector<MessageEntity> = Updates;

@implementation TLUpdates$updateShortSentMessage

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLUpdates$updateShortSentMessage serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLUpdates$updateShortSentMessage *result = [[TLUpdates$updateShortSentMessage alloc] init];
    
    int32_t flags = [is readInt32];
    
    result.flags = flags;
    
    result.n_id = [is readInt32];
    result.pts = [is readInt32];
    result.pts_count = [is readInt32];
    result.date = [is readInt32];
    
    if (flags & (1 << 9))
    {
        int32_t signature = [is readInt32];
        result.media = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 7))
    {
        __unused int32_t vectorSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [items addObject:object];
            }
        }
        result.entities = items;
    }
    
    return result;
}

@end
