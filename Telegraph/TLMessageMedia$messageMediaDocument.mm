#import "TLMessageMedia$messageMediaDocument.h"

#import "TLMetaClassStore.h"

//messageMediaDocument flags:# document:flags.0?Document caption:flags.1?string ttl_seconds:flags.2?int = MessageMedia;

@implementation TLMessageMedia$messageMediaDocument

- (int32_t)TLconstructorName {
    return -1;
}

- (int32_t)TLconstructorSignature {
    return 0;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    assert(false);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLMessageMedia$messageMediaDocument *result = [[TLMessageMedia$messageMediaDocument alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 0)) {
        int32_t signature = [is readInt32];
        result.document = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (flags & (1 << 1)) {
        result.caption = [is readString];
    }
    
    if (flags & (1 << 2)) {
        result.ttl_seconds = [is readInt32];
    }
    
    return result;
}

@end
