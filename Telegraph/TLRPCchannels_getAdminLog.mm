#import "TLRPCchannels_getAdminLog.h"

#import "TL/TLMetaScheme.h"

#import "TLMetaClassStore.h"

@implementation TLRPCchannels_getAdminLog

- (int32_t)TLconstructorSignature
{
    return 0x33ddf480;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLchannels_AdminLogResults class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 68;
}

//channels.getAdminLog#38910619 flags:# channel:InputChannel q:string events_filter:flags.0?ChannelAdminLogEventsFilter user_id:flags.1?InputUser max_id:long min_id:long limit:int = channels.AdminLogResults;


- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:self.flags];
    
    TLMetaClassStore::serializeObject(os, self.channel, true);
    [os writeString:self.q];
    
    if (self.flags & (1 << 0)) {
        TLMetaClassStore::serializeObject(os, self.events_filter, true);
    }
    
    if (self.flags & (1 << 1)) {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        
        [os writeInt32:(int32_t)self.admins.count];
        for (TLInputUser *item in self.admins) {
            TLMetaClassStore::serializeObject(os, item, true);
        }
    }
    
    [os writeInt64:self.max_id];
    [os writeInt64:self.min_id];
    [os writeInt32:self.limit];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    return nil;
}

@end
