#import "TGCheckPasswordActor.h"

#import "ActionStage.h"
#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGUser+Telegraph.h"
#import "TGUserDataRequestBuilder.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTProto.h>
#import <MTProtoKit/MTRequest.h>
#import <MTProtoKit/MTEncryption.h>

@interface TGCheckPasswordActor ()
{
    NSString *_plaintextPassword;
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
    if ([password isKindOfClass:[TLaccount_Password$account_noPassword class]])
    {
        [ActionStageInstance() actionCompleted:self.path result:nil];
    }
    else
    {
        TLaccount_Password$account_password *concretePassword = (TLaccount_Password$account_password *)password;
        
        MTRequest *request = [[MTRequest alloc] init];
        request.dependsOnPasswordEntry = false;
        TLRPCauth_checkPassword$auth_checkPassword *checkPassword = [[TLRPCauth_checkPassword$auth_checkPassword alloc] init];
        
        NSMutableData *data = [[NSMutableData alloc] init];
        [data appendData:concretePassword.current_salt];
        [data appendData:[_plaintextPassword dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:concretePassword.current_salt];
        NSData *currentPasswordHash = MTSha256(data);
        
        checkPassword.password_hash = currentPasswordHash;
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
