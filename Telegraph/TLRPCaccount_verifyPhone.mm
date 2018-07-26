#import "TLRPCaccount_verifyPhone.h"

#import "TLMetaClassStore.h"

@implementation TLRPCaccount_verifyPhone

- (int32_t)TLconstructorSignature
{
    return 0x4dd3a7f6;
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
    return 78;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeString:_phone_number];
    [os writeString:_phone_code_hash];
    [os writeString:_phone_code];

}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCaccount_verifyPhone deserialization not supported");
    return nil;
}

@end

