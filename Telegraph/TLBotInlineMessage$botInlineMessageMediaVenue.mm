#import "TLBotInlineMessage$botInlineMessageMediaVenue.h"

#import "TLMetaClassStore.h"

//botInlineMessageMediaVenue flags:# geo:GeoPoint title:string address:string provider:string venue_id:string reply_markup:flags.2?ReplyMarkup = BotInlineMessage;

@implementation TLBotInlineMessage$botInlineMessageMediaVenue

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLBotInlineMessage$botInlineMessageMediaVenue serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLBotInlineMessage$botInlineMessageMediaVenue *result = [[TLBotInlineMessage$botInlineMessageMediaVenue alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    {
        int32_t signature = [is readInt32];
        result.geo_point = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    result.title = [is readString];
    result.address = [is readString];
    result.provider = [is readString];
    result.venue_id = [is readString];
    
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
