#import "TGRevokeSessionsActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

#import "TGTelegramNetworking.h"

@implementation TGRevokeSessionsActor

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

+ (NSString *)genericPath
{
    return @"/tg/service/revokesessions";
}

- (void)execute:(NSDictionary *)__unused options
{
    [[TGTelegramNetworking instance] clearExportedTokens];
    
    self.cancelToken = [TGTelegraphInstance doRevokeOtherSessions:self];
}

- (void)revokeSessionsSuccess
{
    [ActionStageInstance() requestActor:@"/tg/service/settings/push/(subscribe)" options:nil watcher:self];
}

- (void)revokeSessionsFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)actorCompleted:(int)__unused status path:(NSString *)__unused path result:(id)__unused result
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
