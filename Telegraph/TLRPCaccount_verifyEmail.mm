#import "TLRPCaccount_verifyEmail.h"

#import "TLMetaClassStore.h"

@implementation TLRPCaccount_verifyEmail

- (int32_t)TLconstructorSignature
{
    return 0xecba39db;
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
    [os writeString:_email];
    [os writeString:_code];
    
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCaccount_verifyEmail deserialization not supported");
    return nil;
}

@end
