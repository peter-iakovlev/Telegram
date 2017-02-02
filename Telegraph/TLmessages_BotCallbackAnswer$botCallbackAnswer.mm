#import "TLmessages_BotCallbackAnswer$botCallbackAnswer.h"

#import "TLMetaClassStore.h"

//messages.botCallbackAnswerMeta flags:# alert:flags.1?true message:flags.0?string url:flags.2?string has_url:flags.3?true cache_time:int = messages.BotCallbackAnswer;

@implementation TLmessages_BotCallbackAnswer$botCallbackAnswer

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLmessages_BotCallbackAnswer$botCallbackAnswer serialization not supported");
}

- (bool)alert {
    return self.flags & (1 << 1);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLmessages_BotCallbackAnswer$botCallbackAnswer *result = [[TLmessages_BotCallbackAnswer$botCallbackAnswer alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 0))
    {
        result.message = [is readString];
    }
    
    if (flags & (1 << 2)) {
        result.url = [is readString];
    }
    
    result.cache_time = [is readInt32];
    
    return result;
}

@end
