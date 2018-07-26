#import "TLRPChelp_acceptTermsOfService.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"


@implementation TLRPChelp_acceptTermsOfService

- (int32_t)TLconstructorSignature
{
    return 0xee72f79a;
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
    return 80;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TLMetaClassStore::serializeObject(os, self.n_id, true);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPChelp_acceptTermsOfService deserialization not supported");
    return nil;
}

@end

