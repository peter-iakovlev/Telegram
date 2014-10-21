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

- (NSString *)extractErrorType:(TLError *)error
{
    if ([error isKindOfClass:[TLError$richError class]])
    {
        if (((TLError$richError *)error).type.length != 0)
            return ((TLError$richError *)error).type;
        
        NSString *errorDescription = nil;
        if ([error isKindOfClass:[TLError$error class]])
            errorDescription = ((TLError$error *)error).text;
        else if ([error isKindOfClass:[TLError$richError class]])
            errorDescription = ((TLError$richError *)error).n_description;
        
        NSMutableString *errorString = [[NSMutableString alloc] init];
        for (int i = 0; i < (int)errorDescription.length; i++)
        {
            unichar c = [errorDescription characterAtIndex:i];
            if (c == ':')
                break;
            
            [errorString appendString:[[NSString alloc] initWithCharacters:&c length:1]];
        }
        
        if (errorString.length != 0)
            return errorString;
    }
    
    return nil;
}

- (void)execute:(NSDictionary *)options
{
    MTRequest *request = [[MTRequest alloc] init];
    
    TLRPCaccount_checkUsername$account_checkUsername *checkUsername = [[TLRPCaccount_checkUsername$account_checkUsername alloc] init];
    checkUsername.username = options[@"username"];
    
    request.body = checkUsername;
    
    __weak TGCheckUsernameAvailabilityActor *weakSelf = self;
    request.completed = ^(NSNumber *result, __unused NSTimeInterval date, TLError *error)
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
