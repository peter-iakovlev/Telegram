#import "TGUpdateUserStatusesActor.h"

#import "TGTelegraph.h"

#import "TGUserDataRequestBuilder.h"

#import "ActionStage.h"

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

- (void)contactStatusesRequestSuccess:(NSArray *)contactStatuses currentDate:(int)currentDate
{
    std::tr1::shared_ptr<std::map<int, TGUserPresence> > presenceMap(new std::map<int, TGUserPresence>());
    
    for (TLContactStatus *statusDesc in contactStatuses)
    {
        TGUserPresence presence;
        presence.online = statusDesc.expires >= currentDate;
        presence.lastSeen = statusDesc.expires;
        (*presenceMap)[statusDesc.user_id] = presence;
    }
    
    [TGTelegraphInstance dispatchMultipleUserPresenceChanges:presenceMap];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)contactStatusesRequestFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
