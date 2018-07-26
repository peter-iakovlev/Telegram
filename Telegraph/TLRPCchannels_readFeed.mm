#import "TLRPCchannels_readFeed.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

@implementation TLRPCchannels_readFeed

- (int32_t)TLconstructorSignature
{
    return 0x9c3011d;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [NSNumber class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 76;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_feed_id];
    
    TLMetaClassStore::serializeObject(os, _max_position, true);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCchannels_readFeed deserialization not supported");
    return nil;
}

@end
