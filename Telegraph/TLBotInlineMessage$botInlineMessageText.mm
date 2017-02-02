#import "TLBotInlineMessage$botInlineMessageText.h"

#import "TLMetaClassStore.h"

//botInlineMessageText flags:# message:string no_webpage:flags.0?true entities:flags.1?Vector<MessageEntity> reply_markup:flags.2?ReplyMarkup = BotInlineMessage;

@implementation TLBotInlineMessage$botInlineMessageText

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLBotInlineMessage$botContextMessageText serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLBotInlineMessage$botInlineMessageText *result = [[TLBotInlineMessage$botInlineMessageText alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.message = [is readString];
    
    if (flags & (1 << 0)) {
        result.no_webpage = true;
    }
    
    if (flags & (1 << 1)) {
        [is readInt32];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        int32_t count = [is readInt32];
        for (int32_t i = 0; i < count; i++) {
            int32_t signature = [is readInt32];
            id item = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (item != nil) {
                [items addObject:item];
            }
        }
        
        result.entities = items;
    }
    
    if (flags & (1 << 2))
    {
        int32_t signature = [is readInt32];
        result.reply_markup = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
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
