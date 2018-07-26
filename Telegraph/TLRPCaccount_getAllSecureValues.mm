#import "TLRPCaccount_getAllSecureValues.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"


@implementation TLRPCaccount_getAllSecureValues

- (int32_t)TLconstructorSignature
{
    return 0xb288bc7d;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [NSArray class];
}

- (int)impliedResponseSignature
{
    return 0x9f8a6a9b;
}

- (int)layerVersion
{
    return 78;
}

- (void)TLserialize:(NSOutputStream *)os
{
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCaccount_getAllSecureValues deserialization not supported");
    return nil;
}

@end

