#import "TLRPCmessages_forwardMessages.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

@implementation TLRPCmessages_forwardMessages$messages_forwardMessages

- (int32_t)TLconstructorSignature
{
    return 0x708e0195;
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

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:self.flags];
    
    TLMetaClassStore::serializeObject(os, self.from_peer, true);
    
    int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
    [os writeInt32:vectorSignature];
    [os writeInt32:(int32_t)self.n_id.count];
    for (NSNumber *n_id in self.n_id) {
        [os writeInt32:n_id.int32Value];
    }
    
    [os writeInt32:vectorSignature];
    [os writeInt32:(int32_t)self.random_id.count];
    for (NSNumber *random_id in self.random_id) {
        [os writeInt64:random_id.int64Value];
    }
    
    TLMetaClassStore::serializeObject(os, self.to_peer, true);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_forwardMessages deserialization not supported");
    return nil;
}

@end
