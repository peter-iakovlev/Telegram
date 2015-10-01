#import "TGTwoStepConfigSignal.h"

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
            return [SSignal single:[[TGTwoStepConfig alloc] initWithNextSalt:((TLaccount_Password$account_noPassword *)result).n_new_salt currentSalt:nil hasRecovery:false currentHint:nil unconfirmedEmailPattern:((TLaccount_Password$account_noPassword *)result).email_unconfirmed_pattern]];
        }
        else if ([result isKindOfClass:[TLaccount_Password$account_password class]])
        {
            return [SSignal single:[[TGTwoStepConfig alloc] initWithNextSalt:((TLaccount_Password$account_password *)result).n_new_salt currentSalt:((TLaccount_Password$account_password *)result).current_salt hasRecovery:((TLaccount_Password$account_password *)result).has_recovery currentHint:((TLaccount_Password$account_password *)result).hint unconfirmedEmailPattern:((TLaccount_Password$account_password *)result).email_unconfirmed_pattern]];
        }
        else
        {
            NSAssert(false, @"Should not happen");
            return [SSignal fail:nil];
        }
    }];
}

@end
