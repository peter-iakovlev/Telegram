#import "TGCheckPasswordActor.h"

#import <LegacyComponents/ActionStage.h>
#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGTwoStepConfig.h"
#import "TGTwoStepUtils.h"

#import "TGUser+Telegraph.h"
#import "TGUserDataRequestBuilder.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTRequest.h>
#import <MTProtoKit/MTEncryption.h>

@interface TGCheckPasswordActor ()
{
    NSString *_plaintextPassword;
    TGTwoStepConfig *_twoStepConfig;
}

@end

@implementation TGCheckPasswordActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/checkPassword/@";
}

- (void)execute:(NSDictionary *)options
{
    _plaintextPassword = options[@"password"];
    _twoStepConfig = options[@"twoStepConfig"];
    
    MTRequest *request = [[MTRequest alloc] init];
    request.dependsOnPasswordEntry = false;
    request.body = [[TLRPCaccount_getPassword$account_getPassword alloc] init];
    
    __weak TGCheckPasswordActor *weakSelf = self;
    [request setCompleted:^(TLaccount_Password *password, __unused NSTimeInterval timestamp, MTRpcError *error)
    {
        __strong TGCheckPasswordActor *strongSelf = weakSelf;
        if (error == nil)
            [strongSelf passwordRequestSuccess:password];
        else
            [strongSelf passwordRequestFailed:error.errorDescription];
    }];
    
    self.cancelToken = request.internalId;
    
    [[TGTelegramNetworking instance] addRequest:request];
}

- (void)passwordRequestSuccess:(TLaccount_Password *)password
{
    if (password.flags & (1 << 2))
    {
        MTRequest *request = [[MTRequest alloc] init];
        request.dependsOnPasswordEntry = false;
        TLRPCauth_checkPassword$auth_checkPassword *checkPassword = [[TLRPCauth_checkPassword$auth_checkPassword alloc] init];
        checkPassword.password = [TGTwoStepUtils srpPasswordWithPassword:_plaintextPassword algo:_twoStepConfig.currentAlgo srpId:_twoStepConfig.srpId srpB:_twoStepConfig.srpB];
        
        request.body = checkPassword;
        
        __weak TGCheckPasswordActor *weakSelf = self;
        [request setCompleted:^(TLauth_Authorization *auth, __unused NSTimeInterval timestamp, MTRpcError *error)
        {
            __strong TGCheckPasswordActor *strongSelf = weakSelf;
            if (error == nil)
                [strongSelf checkPasswordSuccess:auth];
            else
                [strongSelf checkPasswordFailed:error.errorDescription];
        }];
        
        request.shouldContinueExecutionWithErrorContext = ^bool (__unused MTRequestErrorContext *errorContext)
        {
            return false;
        };
        
        self.cancelToken = request.internalId;
        [[TGTelegramNetworking instance] addRequest:request];
    }
    else
    {
        [ActionStageInstance() actionCompleted:self.path result:nil];
    }
}

- (void)passwordRequestFailed:(NSString *)__unused errorText
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)checkPasswordSuccess:(TLauth_Authorization *)auth
{    
    TGUser *user = [[TGUser alloc] initWithTelegraphUserDesc:auth.user];
    [TGUserDataRequestBuilder executeUserObjectsUpdate:@[user]];
    [ActionStageInstance() actionCompleted:self.path result:@{@"userId": @(user.uid)}];
}

- (void)checkPasswordFailed:(NSString *)__unused errorText
{
    int errorCode = TGCheckPasswordErrorCodeInvalidPassword;
    if ([errorText rangeOfString:@"PASSWORD_HASH_INVALID"].location != NSNotFound)
        errorCode = TGCheckPasswordErrorCodeInvalidPassword;
    else if ([errorText rangeOfString:@"FLOOD_WAIT"].location != NSNotFound)
        errorCode = TGCheckPasswordErrorCodeFlood;
    
    [ActionStageInstance() actionFailed:self.path reason:errorCode];
}

@end
