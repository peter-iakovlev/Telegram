#import "TGPushActionsRequestBuilder.h"

#import "TGAppDelegate.h"

#import "TGTelegraph.h"

static NSString *devicePushToken = nil;

@interface TGPushActionsRequestBuilder () <TGDeviceTokenListener>

@end

@implementation TGPushActionsRequestBuilder

+ (NSString *)genericPath
{
    return @"/tg/service/settings/push/@";
}

- (void)execute:(NSDictionary *)__unused options
{
    if (devicePushToken == nil)
    {
        [TGAppDelegateInstance requestDeviceToken:self];
        
        [ActionStageInstance() actionFailed:self.path reason:-1];
        
        return;
    }
    
    NSRange range;
    range.location = [@"/tg/service/settings/push/(" length];
    range.length = [self.path length] - 1 - range.location;
    NSString *action = [self.path substringWithRange:range];
    
    if ([action isEqualToString:@"subscribe"])
    {
        self.cancelToken = [TGTelegraphInstance doUpdatePushSubscription:true deviceToken:devicePushToken requestBuilder:self];
    }
    else if ([action isEqualToString:@"unsubscribe"])
    {
        self.cancelToken = [TGTelegraphInstance doUpdatePushSubscription:false deviceToken:devicePushToken requestBuilder:self];
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)deviceTokenRequestCompleted:(NSString *)deviceToken
{
    if (deviceToken != nil)
    {
        devicePushToken = deviceToken;
        [self execute:nil];
    }
    else
    {
        [self pushSubscriptionUpdateFailed];
    }
}

- (void)pushSubscriptionUpdateSuccess
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)pushSubscriptionUpdateFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
