#import "TLPageBlock$pageBlockEmbed.h"

#import "TLMetaClassStore.h"

//pageBlockEmbed#cde200d1 flags:# full_width:flags.0?true allow_scrolling:flags.3?true url:flags.1?string html:flags.2?string poster_photo_id:flags.4?long w:int h:int caption:RichText = PageBlock;

@implementation TLPageBlock$pageBlockEmbed

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLPageBlock$pageBlockEmbed serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLPageBlock$pageBlockEmbed *result = [[TLPageBlock$pageBlockEmbed alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 1)) {
        result.url = [is readString];
    }
    
    if (flags & (1 << 2)) {
        result.html = [is readString];
    }
    
    if (flags & (1 << 4)) {
        result.poster_photo_id = [is readInt64];
    }
    
    result.w = [is readInt32];
    result.h = [is readInt32];
    
    {
        int32_t signature = [is readInt32];
        result.caption = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    return result;
}


@end
