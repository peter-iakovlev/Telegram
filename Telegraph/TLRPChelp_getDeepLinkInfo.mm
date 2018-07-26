#import "TLRPChelp_getDeepLinkInfo.h"

#import "TLMetaClassStore.h"

@implementation TLRPChelp_getDeepLinkInfo

- (int32_t)TLconstructorSignature
{
    return 0x3fedc75f;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLhelp_DeepLinkInfo class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 78;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeString:_path];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPChelp_getDeepLinkInfo deserialization not supported");
    return nil;
}

@end
