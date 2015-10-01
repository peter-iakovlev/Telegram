#import "TGAccountSignals.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>

@implementation TGAccountSignals

+ (SSignal *)deleteAccount
{
    TLRPCaccount_deleteAccount$account_deleteAccount *deleteAccount = [[TLRPCaccount_deleteAccount$account_deleteAccount alloc] init];
    deleteAccount.reason = @"Forgot password";
    return [[[TGTelegramNetworking instance] requestSignal:deleteAccount requestClass:TGRequestClassIgnorePasswordEntryRequired] mapToSignal:^SSignal *(__unused id result)
    {
        [[[TGTelegramNetworking instance] context] updatePasswordInputRequiredForDatacenterWithId:[[TGTelegramNetworking instance] mtProto].datacenterId required:false];
        
        return [SSignal complete];
    }];
}

@end
