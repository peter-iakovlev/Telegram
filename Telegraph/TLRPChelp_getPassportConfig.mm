#import "TLRPChelp_getPassportConfig.h"

#import "TLMetaClassStore.h"

@implementation TLRPChelp_getPassportConfig

- (int32_t)TLconstructorSignature
{
    return 0xc661ad08;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLhelp_PassportConfig class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 85;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_n_hash];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPChelp_getPassportConfig deserialization not supported");
    return nil;
}

@end
