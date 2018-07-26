#import "TLRPCmessages_report.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"


@implementation TLRPCmessages_report

- (int32_t)TLconstructorSignature
{
    return 0xbd82b658;
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
    TLMetaClassStore::serializeObject(os, self.peer, true);
    
    int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
    [os writeInt32:vectorSignature];
    [os writeInt32:(int32_t)self.n_id.count];
    for (NSNumber *mid in self.n_id) {
        [os writeInt32:mid.int32Value];
    }
    
    TLMetaClassStore::serializeObject(os, self.reason, true);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_report deserialization not supported");
    return nil;
}

@end
