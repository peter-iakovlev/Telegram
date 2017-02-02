#import "TLBotInlineResult$botInlineResult.h"

#import "TLMetaClassStore.h"

//botInlineResult#9bebaeb9 flags:# id:string type:string title:flags.1?string description:flags.2?string url:flags.3?string thumb_url:flags.4?string content_url:flags.5?string content_type:flags.5?string w:flags.6?int h:flags.6?int duration:flags.7?int send_message:BotInlineMessage = BotInlineResult;

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
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    return result;
}

- (bool)isMedia {
    return self.flags & (1 << 0);
}

@end
