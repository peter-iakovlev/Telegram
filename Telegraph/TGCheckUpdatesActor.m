#import "TGCheckUpdatesActor.h"

#import "TGTelegraph.h"

#import <LegacyComponents/ActionStage.h>

#import "TGApplication.h"
#import "TGAppDelegate.h"

#import "TGUpdateAppInfo.h"

@implementation TGCheckUpdatesActor

+ (NSString *)genericPath
{
    return @"/tg/service/checkUpdates";
}

- (void)execute:(NSDictionary *)__unused options
{
    self.cancelToken = [TGTelegraphInstance doCheckUpdates:self];
}

- (void)checkUpdatesSuccess:(TLhelp_AppUpdate *)updateDesc
{
//    TGDispatchOnMainThread(^{
//        [TGAppDelegateInstance presentUpdateAppController:[TGUpdateAppInfo demo]];
//    });
//    return;
    if ([updateDesc isKindOfClass:[TLhelp_AppUpdate$help_appUpdateMeta class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            TLhelp_AppUpdate$help_appUpdateMeta *concreteUpdate = (TLhelp_AppUpdate$help_appUpdateMeta *)updateDesc;
            
            TGUpdateAppInfo *updateInfo = [[TGUpdateAppInfo alloc] initWithTL:concreteUpdate];
            [TGAppDelegateInstance presentUpdateAppController:updateInfo];
        });
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)checkUpdatesFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
