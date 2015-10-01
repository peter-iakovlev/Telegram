#import "TGDeleteAccountActor.h"

#import "ActionStage.h"

#import "TGTelegramNetworking.h"

#import "TL/TLMetaScheme.h"

#import <MTProtoKit/MTRequest.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTContext.h>

@implementation TGDeleteAccountActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/deleteAccount";
}

- (void)execute:(NSDictionary *)__unused options
{
    MTRequest *request = [[MTRequest alloc] init];
    
    TLRPCaccount_deleteAccount$account_deleteAccount *deleteAccount = [[TLRPCaccount_deleteAccount$account_deleteAccount alloc] init];
    deleteAccount.reason = @"Forgot password";
    request.dependsOnPasswordEntry = false;
    request.body = deleteAccount;
    
    __weak TGDeleteAccountActor *weakSelf = self;
    [request setCompleted:^(id result, __unused NSTimeInterval timestamp, id error)
    {
        __strong TGDeleteAccountActor *strongSelf = weakSelf;
        if (error == nil)
            [strongSelf deleteAccountSuccess:result];
        else
            [strongSelf deleteAccountFailed:[[TGTelegramNetworking instance] extractNetworkErrorType:error]];
    }];
    
    self.cancelToken = request.internalId;
    [[TGTelegramNetworking instance] addRequest:request];
}
     
- (void)deleteAccountSuccess:(id)__unused result
{
    [[[TGTelegramNetworking instance] context] updatePasswordInputRequiredForDatacenterWithId:[[TGTelegramNetworking instance] mtProto].datacenterId required:false];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)deleteAccountFailed:(NSString *)__unused errorText
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
