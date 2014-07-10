#import "TGSendInvitesActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"

@implementation TGSendInvitesActor

+ (NSString *)genericPath
{
    return @"/tg/auth/sendinvites/@";
}

- (void)execute:(NSDictionary *)__unused options
{
    NSString *text = [options objectForKey:@"text"];
    NSArray *phones = [options objectForKey:@"phones"];
    
    self.cancelToken = [TGTelegraphInstance doSendInvites:phones text:text actor:self];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)sendInvitesSuccess
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)sendInvitesFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
