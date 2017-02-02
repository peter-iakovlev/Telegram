#import "TLRPCaccount_sendConfirmPhoneCode.h"

#import "TL/TLMetaScheme.h"

@implementation TLRPCaccount_sendConfirmPhoneCode

- (int32_t)TLconstructorSignature
{
    return 0x1516d7bd;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLauth_SentCode class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 54;
}

- (void)TLserialize:(NSOutputStream *)os
{
    int32_t flags = 0;
    
    [os writeInt32:flags];
    
    [os writeString:_n_hash];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCaccount_sendConfirmPhoneCode deserialization not supported");
    return nil;
}


@end
