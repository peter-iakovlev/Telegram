#import "TLaccount_PasswordInputSettings_manual.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

//account.passwordInputSettings#c23727c9 flags:# new_algo:flags.0?PasswordKdfAlgo new_password_hash:flags.0?bytes hint:flags.0?string email:flags.1?string new_secure_settings:flags.2?SecureSecretSettings = account.PasswordInputSettings;


@implementation TLaccount_PasswordInputSettings_manual

- (int32_t)TLconstructorName
{
    return -1;
}

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc23727c9;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_flags];
    
    if (_flags & (1 << 0))
    {
        TLMetaClassStore::serializeObject(os, _n_new_algo, true);
        [os writeBytes:_n_new_password_hash];
        [os writeString:_hint];
    }
    
    if (_flags & (1 << 1))
    {
        [os writeString:_email];
    }
    
    if (_flags & (1 << 2))
    {
        TLMetaClassStore::serializeObject(os, _n_new_secure_settings, true);
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLaccount_PasswordInputSettings_manual deserialization not supported");
    return nil;
}

@end
