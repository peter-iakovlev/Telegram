#import "TGResetPeerNotificationsActor.h"

#import "ActionStage.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

@implementation TGResetPeerNotificationsActor

+ (NSString *)genericPath
{
    return @"/tg/resetPeerSettings";
}

- (void)execute:(NSDictionary *)__unused options
{
    [TGDatabaseInstance() clearPeerNotificationSettings:true];
    
    [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
