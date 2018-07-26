#import "TLRPCaccount_getSecureValue.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"


@implementation TLRPCaccount_getSecureValue

- (int32_t)TLconstructorSignature
{
    return 0x73665bc2;
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
    int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
    [os writeInt32:vectorSignature];
    
    [os writeInt32:(int32_t)self.types.count];
    for (TLSecureValueType *type in self.types) {
        TLMetaClassStore::serializeObject(os, type, true);
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCaccount_getSecureValue deserialization not supported");
    return nil;
}

@end
