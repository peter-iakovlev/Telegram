#import "TLBotInlineResult$botInlineResult.h"

#import "TLMetaClassStore.h"

@implementation TLBotInlineResult$botInlineResult

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLBotInlineResult$botInlineResult serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLBotInlineResult$botInlineResult *result = [[TLBotInlineResult$botInlineResult alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.n_id = [is readString];
    result.type = [is readString];
    
    if (flags & (1 << 1)) {
        result.title = [is readString];
    }
    
    if (flags & (1 << 2)) {
        result.n_description = [is readString];
    }
    
    if (flags & (1 << 3)) {
        result.url = [is readString];
    }
    
    if (flags & (1 << 4)) {
        result.thumb_url = [is readString];
    }
    
    if (flags & (1 << 5)) {
        result.content_url = [is readString];
        result.content_type = [is readString];
    }
    
    if (flags & (1 << 6)) {
        result.w = [is readInt32];
        result.h = [is readInt32];
    }
    
    if (flags & (1 << 7)) {
        result.duration = [is readInt32];
    }
    
    {
        int32_t signature = [is readInt32];
        result.send_message = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    return result;
}

- (bool)isMedia {
    return self.flags & (1 << 0);
}

@end
