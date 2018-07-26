#import "TLRPCaccount_acceptAuthorization.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"


@implementation TLRPCaccount_acceptAuthorization

- (int32_t)TLconstructorSignature
{
    return 0xe7027c94;
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
    [os writeInt32:self.bot_id];
    
    [os writeString:self.scope];
    
    [os writeString:self.public_key];
    
    {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        
        [os writeInt32:(int32_t)self.value_hashes.count];
        for (TLSecureValueHash *hash in self.value_hashes) {
            TLMetaClassStore::serializeObject(os, hash, true);
        }
    }
    
    TLMetaClassStore::serializeObject(os, self.credentials, true);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCaccount_acceptAuthorization deserialization not supported");
    return nil;
}

@end


