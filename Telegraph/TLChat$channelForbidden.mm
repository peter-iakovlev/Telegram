#import "TLChat$channelForbidden.h"

#import "TLMetaClassStore.h"

//channelForbidden#289da732 flags:# broadcast:flags.5?true megagroup:flags.8?true id:int access_hash:long title:string until_date:flags.16?int = Chat;

@implementation TLChat$channelForbidden

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
    TLChat$channelForbidden *result = [[TLChat$channelForbidden alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.n_id = [is readInt32];
    result.access_hash = [is readInt64];
    result.title = [is readString];
    
    if (flags & (1 << 16)) {
        result.until_date = [is readInt32];
    }
    
    return result;
}


@end
