#import "TGTwoStepConfigSignal.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

@implementation TGTwoStepConfigSignal

+ (SSignal *)twoStepConfig
{
    TLRPCaccount_getPassword$account_getPassword *getPassword = [[TLRPCaccount_getPassword$account_getPassword alloc] init];
    
    return [[[TGTelegramNetworking instance] requestSignal:getPassword] mapToSignal:^SSignal *(TLaccount_Password *result)
    {
        if ([result isKindOfClass:[TLaccount_Password$account_passwordMeta class]])
        {
            TLaccount_Password$account_passwordMeta *password = (TLaccount_Password$account_passwordMeta *)result;
            
            TGTwoStepConfig *config = [[TGTwoStepConfig alloc] initWithHasPassword:(password.flags & (1 << 2)) hasRecovery:(password.flags & (1 << 0)) hasSecureValues:(password.flags & (1 << 1)) currentAlgo:[TGPasswordKdfAlgo algoWithTL:password.current_algo] currentHint:password.hint unconfirmedEmailPattern:password.email_unconfirmed_pattern nextAlgo:[TGPasswordKdfAlgo algoWithTL:password.n_new_algo] nextSecureAlgo:[TGSecurePasswordKdfAlgo algoWithTL:password.n_new_secure_algo] secureRandom:password.secure_random srpId:password.srp_id srpB:password.srp_B];
            return [SSignal single:config];
        }
        else
        {
            NSAssert(false, @"Should not happen");
            return [SSignal fail:nil];
        }
    }];
}

@end
