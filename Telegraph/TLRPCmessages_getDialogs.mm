#import "TLRPCmessages_getDialogs.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"


@implementation TLRPCmessages_getDialogs

- (int32_t)TLconstructorSignature
{
    return 0x191ba9c5;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLmessages_Dialogs class];
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
    
    [os writeInt32:self.offset_date];
    
    [os writeInt32:self.offset_id];
    
    TLMetaClassStore::serializeObject(os, self.offset_peer, true);

    [os writeInt32:self.limit];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_getDialogs deserialization not supported");
    return nil;
}

@end

