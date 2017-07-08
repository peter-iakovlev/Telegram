#import "TGUpdateUserStatusesActor.h"

#import "TGTelegraph.h"

#import "TGUserDataRequestBuilder.h"

#import "ActionStage.h"

#import "TGUser+Telegraph.h"

@interface TGUpdateUserStatusesActor ()

@end

@implementation TGUpdateUserStatusesActor

+ (NSString *)genericPath
{
    return @"/tg/updateUserStatuses";
}

- (void)execute:(NSDictionary *)__unused options
{
    self.cancelToken = [TGTelegraphInstance doRequestContactStatuses:self];
}

- (void)contactStatusesRequestSuccess:(NSArray *)contactStatuses currentDate:(int)__unused currentDate
{
    std::shared_ptr<std::map<int, TGUserPresence> > presenceMap(new std::map<int, TGUserPresence>());
    
    for (TLContactStatus *statusDesc in contactStatuses)
    {
        (*presenceMap)[statusDesc.user_id] = extractUserPresence(statusDesc.status);
    }
    
    [TGTelegraphInstance dispatchMultipleUserPresenceChanges:presenceMap];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)contactStatusesRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
