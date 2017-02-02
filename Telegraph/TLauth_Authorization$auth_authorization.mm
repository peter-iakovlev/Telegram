#import "TLauth_Authorization$auth_authorization.h"

#import "TLMetaClassStore.h"

@implementation TLauth_Authorization$auth_authorization

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLauth_Authorization$auth_authorization serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLauth_Authorization$auth_authorization *result = [[TLauth_Authorization$auth_authorization alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 0)) {
        result.tmp_sessions = [is readInt32];
    }
    
    {
        int32_t signature = [is readInt32];
        result.user = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    return result;
}

@end
