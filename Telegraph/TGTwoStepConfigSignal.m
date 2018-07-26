#import "TGTwoStepConfigSignal.h"

#import <CommonCrypto/CommonCrypto.h>

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

@implementation TGTwoStepConfigSignal

+ (SSignal *)twoStepConfig
{
    TLRPCaccount_getPassword$account_getPassword *getPassword = [[TLRPCaccount_getPassword$account_getPassword alloc] init];
    
    return [[[TGTelegramNetworking instance] requestSignal:getPassword] mapToSignal:^SSignal *(TLaccount_Password *result)
    {
        if ([result isKindOfClass:[TLaccount_Password$account_noPassword class]])
        {
            return [SSignal single:[[TGTwoStepConfig alloc] initWithNextSalt:((TLaccount_Password$account_noPassword *)result).n_new_salt currentSalt:nil secretRandom:((TLaccount_Password$account_noPassword *)result).secret_random nextSecureSalt:((TLaccount_Password$account_noPassword *)result).n_new_secure_salt hasRecovery:false hasSecureValues:false currentHint:nil unconfirmedEmailPattern:((TLaccount_Password$account_noPassword *)result).email_unconfirmed_pattern]];
        }
        else if ([result isKindOfClass:[TLaccount_Password$account_password class]])
        {
            return [SSignal single:[[TGTwoStepConfig alloc] initWithNextSalt:((TLaccount_Password$account_password *)result).n_new_salt currentSalt:((TLaccount_Password$account_password *)result).current_salt secretRandom:((TLaccount_Password$account_password *)result).secret_random nextSecureSalt:((TLaccount_Password$account_password *)result).n_new_secure_salt hasRecovery:(((TLaccount_Password$account_password *)result).flags & (1 << 0)) hasSecureValues:(((TLaccount_Password$account_password *)result).flags & (1 << 1)) currentHint:((TLaccount_Password$account_password *)result).hint unconfirmedEmailPattern:((TLaccount_Password$account_password *)result).email_unconfirmed_pattern]];
        }
        else
        {
            NSAssert(false, @"Should not happen");
            return [SSignal fail:nil];
        }
    }];
}

+ (NSData *)TGSha512:(NSData *)data
{
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    
    return [[NSData alloc] initWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
}

@end
