#import "TGCheckUpdatesActor.h"

#import "TGTelegraph.h"

#import "ActionStage.h"

#import "TGApplication.h"
#import "TGAppDelegate.h"

#import "TGAlertView.h"

@interface TGUpdateInterface : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSString *updateUrl;

@end

@implementation TGUpdateInterface

@synthesize updateUrl = _updateUrl;

+ (TGUpdateInterface *)instance
{
    static TGUpdateInterface *singleton = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        singleton = [[TGUpdateInterface alloc] init];
    });
    
    return singleton;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (_updateUrl != nil)
        {
            [(TGApplication *)[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:_updateUrl] forceNative:true];
        }
    }
}

@end

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
    if ([updateDesc isKindOfClass:[TLhelp_AppUpdate$help_appUpdate class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            TLhelp_AppUpdate$help_appUpdate *concreteUpdate = (TLhelp_AppUpdate$help_appUpdate *)updateDesc;
            
            TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:concreteUpdate.text delegate:[TGUpdateInterface instance] cancelButtonTitle:TGLocalized(@"Common.Cancel") otherButtonTitles:TGLocalized(@"Update.Update"), nil];
            [TGUpdateInterface instance].updateUrl = concreteUpdate.url;
            [alertView show];
        });
    }
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)checkUpdatesFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
