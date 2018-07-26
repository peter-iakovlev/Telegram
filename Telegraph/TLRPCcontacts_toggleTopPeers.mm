#import "TLRPCcontacts_toggleTopPeers.h"

#import "TLMetaClassStore.h"

@implementation TLRPCcontacts_toggleTopPeers

- (int32_t)TLconstructorSignature
{
    return 0x8514bdda;
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
    return 82;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    [os writeInt32:self.enabled ? TL_BOOL_TRUE_CONSTRUCTOR : TL_BOOL_FALSE_CONSTRUCTOR];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCcontacts_toggleTopPeers deserialization not supported");
    return nil;
}

@end
