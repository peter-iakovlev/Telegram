#import "TLauth_SentCode$auth_sentCode.h"

#import "TLMetaClassStore.h"

//auth.sentCode flags:# type:auth.SentCodeType phone_code_hash:string phone_registered:flags.0?true next_type:flags.1?auth.CodeType timeout:flags.2?int = auth.SentCode;

@implementation TLauth_SentCode$auth_sentCode

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLauth_SentCode$auth_sentCode serialization not supported");
}

- (bool)phone_registered {
    return self.flags & (1 << 0);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLauth_SentCode$auth_sentCode *result = [[TLauth_SentCode$auth_sentCode alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    {
        int32_t signature = [is readInt32];
        result.type = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    result.phone_code_hash = [is readString];
    
    if (flags & (1 << 1)) {
        int32_t signature = [is readInt32];
        result.next_type = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 2)) {
        result.timeout = [is readInt32];
    }
    
    return result;
}


@end
