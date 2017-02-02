#import "TLBotInlineMessage$botInlineMessageMediaContact.h"

#import "TLMetaClassStore.h"

//botInlineMessageMediaContact flags:# phone_number:string first_name:string last_name:string reply_markup:flags.2?ReplyMarkup = BotInlineMessage;

@implementation TLBotInlineMessage$botInlineMessageMediaContact

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLBotInlineMessage$botInlineMessageMediaContact serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLBotInlineMessage$botInlineMessageMediaContact *result = [[TLBotInlineMessage$botInlineMessageMediaContact alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.phone_number = [is readString];
    result.first_name = [is readString];
    result.last_name = [is readString];
    
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
