#import "TLRPChelp_getTermsOfServiceUpdate.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"


@implementation TLRPChelp_getTermsOfServiceUpdate

- (int32_t)TLconstructorSignature
{
    return 0x2ca51fd1;
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
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPChelp_getTermsOfServiceUpdate deserialization not supported");
    return nil;
}

@end
