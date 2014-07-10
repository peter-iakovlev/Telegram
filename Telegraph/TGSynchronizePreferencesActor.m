#import "TGSynchronizePreferencesActor.h"

#import "ActionStage.h"

@implementation TGSynchronizePreferencesActor

+ (NSString *)genericPath
{
    return @"/tg/service/synchronizePreferences";
}

- (void)execute:(NSDictionary *)__unused options
{
    
}

- (void)preferencesRequestSuccess:(TLhelp_AppPrefs *)__unused preferences
{
    
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)preferencesRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
