#import "TLRPCaccount_saveSecureValue.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"


@implementation TLRPCaccount_saveSecureValue

- (int32_t)TLconstructorSignature
{
    return 0x899fe31d;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLSecureValue class];
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
    TLMetaClassStore::serializeObject(os, self.value, true);
    [os writeInt64:self.secure_secret_id];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCaccount_saveSecureValue deserialization not supported");
    return nil;
}

@end
