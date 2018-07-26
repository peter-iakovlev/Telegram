#import "TLRPCaccount_getAuthorizationForm.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"


@implementation TLRPCaccount_getAuthorizationForm

- (int32_t)TLconstructorSignature
{
    return 0xb86ba8e1;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLaccount_AuthorizationForm class];
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
    [os writeInt32:self.bot_id];
    
    [os writeString:self.scope];
    
    [os writeString:self.public_key];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCaccount_getAuthorizationForm deserialization not supported");
    return nil;
}

@end

