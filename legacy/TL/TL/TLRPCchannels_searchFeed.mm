#import "TLRPCchannels_searchFeed.h"

#import "TLMetaClassStore.h"

@implementation TLRPCchannels_searchFeed

- (int32_t)TLconstructorSignature
{
    return 0x88325369;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLmessages_Messages class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 70;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:self.feed_id];
    
    [os writeString:self.q];
    
    [os writeInt32:self.offset_date];
    
    TLMetaClassStore::serializeObject(os, self.offset_peer, true);
    
    [os writeInt32:self.offset_id];
    [os writeInt32:self.limit];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    return nil;
}

@end
