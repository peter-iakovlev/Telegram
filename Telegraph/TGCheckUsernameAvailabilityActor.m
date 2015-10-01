#import "TGCheckUsernameAvailabilityActor.h"

#import "ActionStage.h"

#import "TGTelegramNetworking.h"

#import "TGTelegraph.h"

#import <MTProtoKit/MTRequest.h>

#import "TL/TLMetaScheme.h"

@implementation TGCheckUsernameAvailabilityActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/tg/checkUsernameAvailability/@";
}

- (void)execute:(NSDictionary *)options
{
    MTRequest *request = [[MTRequest alloc] init];
    
    TLRPCaccount_checkUsername$account_checkUsername *checkUsername = [[TLRPCaccount_checkUsername$account_checkUsername alloc] init];
    checkUsername.username = options[@"username"];
    
    request.body = checkUsername;
    
    __weak TGCheckUsernameAvailabilityActor *weakSelf = self;
    request.completed = ^(NSNumber *result, __unused NSTimeInterval date, MTRpcError *error)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            __strong TGCheckUsernameAvailabilityActor *strongSelf = weakSelf;
            if (error == nil)
            {
                [ActionStageInstance() actionCompleted:strongSelf.path result:@{@"usernameValid": result}];
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
