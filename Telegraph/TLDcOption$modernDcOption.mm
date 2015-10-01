#import "TLDcOption$modernDcOption.h"

#import "TLMetaClassStore.h"

@implementation TLDcOption$modernDcOption

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLDcOption$modernDcOption serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLDcOption$modernDcOption *object = [[TLDcOption$modernDcOption alloc] init];
    
    object.flags = [is readInt32];
    object.n_id = [is readInt32];
    object.ip_address = [is readString];
    object.port = [is readInt32];
    
    return object;
}

@end
