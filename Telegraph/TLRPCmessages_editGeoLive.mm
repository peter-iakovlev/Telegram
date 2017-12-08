#import "TLRPCmessages_editGeoLive.h"

#import "TLMetaClassStore.h"

@implementation TLRPCmessages_editGeoLive

- (int32_t)TLconstructorSignature
{
    return 0x9a92304e;
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
    return 73;
}

//messages.editGeoLive#9a92304e flags:# stop:flags.0?true peer:InputPeer id:int geo_point:flags.1?InputGeoPoint = Updates;

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:self.flags];
    
    TLMetaClassStore::serializeObject(os, self.peer, true);
    
    [os writeInt32:self.n_id];
    
    if (self.flags & (1 << 1)) {
        TLMetaClassStore::serializeObject(os, self.geo_point, true);
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    return nil;
}

@end

