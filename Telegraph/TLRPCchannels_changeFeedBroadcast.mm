#import "TLRPCchannels_changeFeedBroadcast.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

@implementation TLRPCchannels_changeFeedBroadcast

- (int32_t)TLconstructorSignature
{
    return 0xffb37511;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLUpdates class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 74;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:self.flags];
    
    TLMetaClassStore::serializeObject(os, self.channel, true);
    
    if (self.flags & (1 << 0)) {
        [os writeInt32:self.feed_id];
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCchannels_changeFeedBroadcast deserialization not supported");
    return nil;
}

@end

