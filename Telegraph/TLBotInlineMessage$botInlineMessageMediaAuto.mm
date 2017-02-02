#import "TLBotInlineMessage$botInlineMessageMediaAuto.h"

#import "TLMetaClassStore.h"

//botInlineMessageMediaAuto flags:# caption:string reply_markup:flags.2?ReplyMarkup = BotInlineMessage;

@implementation TLBotInlineMessage$botInlineMessageMediaAuto

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLBotInlineMessage$botInlineMessageMediaAuto serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLBotInlineMessage$botInlineMessageMediaAuto *result = [[TLBotInlineMessage$botInlineMessageMediaAuto alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.caption = [is readString];
    
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


@end
