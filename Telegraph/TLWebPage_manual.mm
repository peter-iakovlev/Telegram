#import "TLWebPage_manual.h"

#import "TLMetaClassStore.h"

//webPage flags:# id:long url:string display_url:string hash:int type:flags.0?string site_name:flags.1?string title:flags.2?string description:flags.3?string photo:flags.4?Photo embed_url:flags.5?string embed_type:flags.5?string embed_width:flags.6?int embed_height:flags.6?int duration:flags.7?int author:flags.8?string = WebPage;

//webPage flags:# id:long url:string display_url:string hash:int type:flags.0?string site_name:flags.1?string title:flags.2?string description:flags.3?string photo:flags.4?Photo embed_url:flags.5?string embed_type:flags.5?string embed_width:flags.6?int embed_height:flags.6?int duration:flags.7?int author:flags.8?string document:flags.9?Document cached_page:flags.10?Page = WebPage;

@implementation TLWebPage_manual

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLWebPage_manual serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLWebPage_manual *object = [[TLWebPage_manual alloc] init];
    
    object.flags = [is readInt32];
    object.n_id = [is readInt64];
    object.url = [is readString];
    object.display_url = [is readString];
    object.n_hash = [is readInt32];
    
    if (object.flags & (1 << 0))
        object.type = [is readString];
    
    if (object.flags & (1 << 1))
        object.site_name = [is readString];
    
    if (object.flags & (1 << 2))
        object.title = [is readString];
    
    if (object.flags & (1 << 3))
        object.n_description = [is readString];
    
    if (object.flags & (1 << 4))
    {
        int32_t signature = [is readInt32];
        object.photo = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (object.flags & (1 << 5))
    {
        object.embed_url = [is readString];
        object.embed_type = [is readString];
    }
    
    if (object.flags & (1 << 6))
    {
        object.embed_width = [is readInt32];
        object.embed_height = [is readInt32];
    }
    
    if (object.flags & (1 << 7))
        object.duration = [is readInt32];
    
    if (object.flags & (1 << 8))
        object.author = [is readString];
    
    if (object.flags & (1 << 9))
    {
        int32_t signature = [is readInt32];
        object.document = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (object.flags & (1 << 10))
    {
        int32_t signature = [is readInt32];
        object.cached_page = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    return object;
}

@end
