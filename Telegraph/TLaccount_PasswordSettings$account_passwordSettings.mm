#import "TLaccount_PasswordSettings$account_passwordSettings.h"

#import "TLMetaClassStore.h"

@implementation TLaccount_PasswordSettings$account_passwordSettings

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLaccount_PasswordSettings$account_passwordSettings serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLaccount_PasswordSettings$account_passwordSettings *result = [[TLaccount_PasswordSettings$account_passwordSettings alloc] init];
    
    result.flags = [is readInt32];
    
    if (result.flags & (1 << 0)) {
        result.email = [is readString];
    }
    
    if (result.flags & (1 << 1)) {
        int32_t signature = [is readInt32];
        result.secure_settings = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }

    return result;
}

@end
