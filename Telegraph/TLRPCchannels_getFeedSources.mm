#import "TLRPCchannels_getFeedSources.h"

#import "TLchannels_FeedSources.h"

@implementation TLRPCchannels_getFeedSources

- (int32_t)TLconstructorSignature
{
    return 0xd8ce236e;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLchannels_FeedSources class];
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
    
    if (self.flags & (1 << 0)) {
        [os writeInt32:self.feed_id];
    }
    
    [os writeInt32:self.n_hash];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCchannels_getFeedSources deserialization not supported");
    return nil;
}

@end

