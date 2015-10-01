#import "TGApplyUsernameActor.h"

#import "ActionStage.h"

#import "TGTelegramNetworking.h"

#import <MTProtoKit/MTRequest.h>

#import "TL/TLMetaScheme.h"

#import "TGUserDataRequestBuilder.h"

@implementation TGApplyUsernameActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/tg/applyUsername/@";
}

- (void)execute:(NSDictionary *)options
{
    MTRequest *request = [[MTRequest alloc] init];
    
    TLRPCaccount_updateUsername$account_updateUsername *updateUsername = [[TLRPCaccount_updateUsername$account_updateUsername alloc] init];
    updateUsername.username = options[@"username"];
    
    request.body = updateUsername;
    
    __weak TGApplyUsernameActor *weakSelf = self;
    request.completed = ^(TLUser *result, __unused NSTimeInterval date, MTRpcError *error)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            __strong TGApplyUsernameActor *strongSelf = weakSelf;
            if (error == nil)
            {
                [TGUserDataRequestBuilder executeUserDataUpdate:@[result]];
                [ActionStageInstance() actionCompleted:strongSelf.path result:nil];
            }
            else
            {
                [ActionStageInstance() actionFailed:strongSelf.path reason:-1];
            }
        }];
    };
    
    self.cancelToken = request.internalId;
    
    [[TGTelegramNetworking instance] addRequest:request];
}


@end
