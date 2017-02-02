#import "TLBotInlineResult$botInlineMediaResult.h"

#import "TLMetaClassStore.h"

//botInlineMediaResult flags:# id:string type:string photo:flags.0?Photo document:flags.1?Document title:flags.2?string description:flags.3?string send_message:BotInlineMessage = BotInlineResult;

@implementation TLBotInlineResult$botInlineMediaResult

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLBotInlineResult$botInlineMediaResult serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLBotInlineResult$botInlineMediaResult *result = [[TLBotInlineResult$botInlineMediaResult alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.n_id = [is readString];
    result.type = [is readString];
    
    if (flags & (1 << 0))
    {
        int32_t signature = [is readInt32];
        result.photo = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 1))
    {
        int32_t signature = [is readInt32];
        result.document = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 2)) {
        result.title = [is readString];
    }
    
    if (flags & (1 << 3)) {
        result.n_description = [is readString];
    }
    
    {
        int32_t signature = [is readInt32];
        result.send_message = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    return result;
}


@end
