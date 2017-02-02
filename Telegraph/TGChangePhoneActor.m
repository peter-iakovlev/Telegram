#import "TGChangePhoneActor.h"

#import "TGTelegramNetworking.h"
#import <MTProtoKit/MTRequest.h>
#import <MTProtoKit/MTRpcError.h>

#import "TL/TLMetaScheme.h"

#import "TGUserDataRequestBuilder.h"

#import "ActionStage.h"
#import "TGSignInRequestBuilder.h"

@implementation TGChangePhoneActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/changePhoneNumber/@";
}

- (void)execute:(NSDictionary *)options
{
    MTRequest *request = [[MTRequest alloc] init];
    
    TLRPCaccount_changePhone$account_changePhone *changePhone = [[TLRPCaccount_changePhone$account_changePhone alloc] init];
    NSString *phoneNumber = options[@"phoneNumber"];
    if (![phoneNumber hasPrefix:@"+"])
        phoneNumber = [@"+" stringByAppendingString:phoneNumber];
    changePhone.phone_number = phoneNumber;
    changePhone.phone_code_hash = options[@"phoneCodeHash"];
    changePhone.phone_code = options[@"phoneCode"];
    request.body = changePhone;
    
    __weak TGChangePhoneActor *weakSelf = self;
    [request setCompleted:^(TLUser *user, __unused NSTimeInterval timestamp, MTRpcError *error)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            __strong TGChangePhoneActor *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (error == nil)
                    [strongSelf changePhoneSuccess:user];
                else
                    [strongSelf changePhoneFailed:error.errorDescription];
            }
        }];
    }];
    
    self.cancelToken = request.internalId;
    
    [[TGTelegramNetworking instance] addRequest:request];
}

- (void)changePhoneSuccess:(TLUser *)user
{
    [TGUserDataRequestBuilder executeUserDataUpdate:@[user]];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)changePhoneFailed:(NSString *)errorText
{
    int errorCode = TGSignInResultInvalidToken;
    
    if ([errorText isEqualToString:@"PHONE_CODE_INVALID"])
        errorCode = TGSignInResultInvalidToken;
    else if ([errorText isEqualToString:@"PHONE_CODE_EXPIRED"])
        errorCode = TGSignInResultTokenExpired;
    else if ([errorText hasPrefix:@"PHONE_NUMBER_UNOCCUPIED"])
        errorCode = TGSignInResultNotRegistered;
    else if ([errorText hasPrefix:@"FLOOD_WAIT"])
        errorCode = TGSignInResultFloodWait;
    
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
