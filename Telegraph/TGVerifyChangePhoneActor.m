#import "TGVerifyChangePhoneActor.h"

#import "ActionStage.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import <MTProtoKit/MTRequest.h>
#import <MTProtoKit/MTRpcError.h>

#import "TL/TLMetaScheme.h"

#import "TGSendCodeRequestBuilder.h"

#import "TLRPCaccount_sendChangePhoneCode.h"
#import "TLauth_SentCode$auth_sentCode.h"

@implementation TGVerifyChangePhoneActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/verifyChangePhoneNumber/@";
}

- (void)execute:(NSDictionary *)options
{
    MTRequest *request = [[MTRequest alloc] init];
    
    if ([options[@"requestCall"] boolValue])
    {
        TLRPCauth_resendCode$auth_resendCode *sendCall = [[TLRPCauth_resendCode$auth_resendCode alloc] init];
        sendCall.phone_number = options[@"phoneNumber"];
        sendCall.phone_code_hash = options[@"phoneCodeHash"];
        request.body = sendCall;
    }
    else
    {
        TLRPCaccount_sendChangePhoneCode *sendChangePhoneCode = [[TLRPCaccount_sendChangePhoneCode alloc] init];
        sendChangePhoneCode.phone_number = options[@"phoneNumber"];
        request.body = sendChangePhoneCode;
    }
    
    __weak TGVerifyChangePhoneActor *weakSelf = self;
    [request setCompleted:^(id result, __unused NSTimeInterval timestamp, MTRpcError *error)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            __strong TGVerifyChangePhoneActor *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (error == nil)
                {
                    if ([options[@"requestCall"] boolValue])
                        [strongSelf sendCallCompleted];
                    else
                        [strongSelf sendRequestCompleted:result];
                }
                else
                {
                    [strongSelf sendRequestFailed:error.errorDescription];
                }
            }
        }];
    }];
    
    self.cancelToken = request.internalId;
    
    [[TGTelegramNetworking instance] addRequest:request];
}

- (void)sendCallCompleted
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)sendRequestCompleted:(TLauth_SentCode$auth_sentCode *)sentCode
{
    [ActionStageInstance() actionCompleted:self.path result:@{@"phoneCodeHash": sentCode.phone_code_hash, @"callTimeout": @(sentCode.timeout)}];
}

- (void)sendRequestFailed:(NSString *)errorText
{
    TGVerifyChangePhoneError errorCode = TGVerifyChangePhoneErrorServer;
    
    if ([errorText isEqualToString:@"PHONE_NUMBER_INVALID"])
        errorCode = TGVerifyChangePhoneErrorInvalidPhone;
    else if ([errorText hasPrefix:@"FLOOD_WAIT"])
        errorCode = TGVerifyChangePhoneErrorFlood;
    else if ([errorText isEqualToString:@"PHONE_NUMBER_OCCUPIED"])
        errorCode = TGVerifyChangePhoneErrorPhoneOccupied;
    
    [ActionStageInstance() actionFailed:self.path reason:errorCode];
}

@end
