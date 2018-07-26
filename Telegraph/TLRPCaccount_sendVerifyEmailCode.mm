#import "TLRPCaccount_sendVerifyEmailCode.h"

#import "TLMetaClassStore.h"

@implementation TLRPCaccount_sendVerifyEmailCode

- (int32_t)TLconstructorSignature
{
    return 0x7011509f;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLaccount_SentEmailCode class];
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
    [os writeString:_email];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCaccount_sendVerifyEmailCode deserialization not supported");
    return nil;
}

@end
