#import "TGChangePeerBlockStatusActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

@implementation TGChangePeerBlockStatusActor

+ (NSString *)genericPath
{
    return @"/tg/changePeerBlockedStatus/@";
}

- (void)execute:(NSDictionary *)options
{
    int64_t peerId = [[options objectForKey:@"peerId"] longLongValue];
    bool block = [[options objectForKey:@"block"] boolValue];
    
    [TGDatabaseInstance() setPeerIsBlocked:peerId blocked:block writeToActionQueue:true];
    
    [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
    
    [TGDatabaseInstance() loadBlockedList:^(NSArray *blockedList)
    {
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for (NSNumber *nUid in blockedList)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
            if (user != nil)
                [users addObject:user];
        }
        [ActionStageInstance() dispatchResource:@"/tg/blockedUsers" resource:[[SGraphObjectNode alloc] initWithObject:users]];
    }];
    
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
