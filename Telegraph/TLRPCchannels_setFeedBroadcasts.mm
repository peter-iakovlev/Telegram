#import "TLRPCchannels_setFeedBroadcasts.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

@implementation TLRPCchannels_setFeedBroadcasts

- (int32_t)TLconstructorSignature
{
    return 0xea80bfae;
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
    return 76;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:self.flags];
    [os writeInt32:self.feed_id];
    
    if (self.flags & (1 << 0)) {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        [os writeInt32:(int32_t)self.channels.count];
        for (TLInputChannel *channel in self.channels) {
            TLMetaClassStore::serializeObject(os, channel, true);
        }
    }
    
    if (self.flags & (1 << 1)) {
        [os writeInt32:self.also_newly_joined ? TL_BOOL_TRUE_CONSTRUCTOR : TL_BOOL_FALSE_CONSTRUCTOR];
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCchannels_setFeedBroadcasts deserialization not supported");
    return nil;
}

@end

