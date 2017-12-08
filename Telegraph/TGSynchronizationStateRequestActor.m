#import "TGSynchronizationStateRequestActor.h"

#import <LegacyComponents/ActionStage.h>
#import <LegacyComponents/SGraphObjectNode.h>

#import "TGTelegramNetworking.h"

@implementation TGSynchronizationStateRequestActor

+ (NSString *)genericPath
{
    return @"/tg/service/synchronizationstate";
}

- (void)execute:(NSDictionary *)__unused options
{
    int state = [ActionStageInstance() requestActorStateNow:@"/tg/service/updatestate"] ? 1 : 0;
    if ([[TGTelegramNetworking maybeInstance] isUpdating])
        state |= 1;
    if ([[TGTelegramNetworking maybeInstance] isConnecting])
        state |= 2;
    if (![[TGTelegramNetworking maybeInstance] isNetworkAvailable])
        state |= 4;
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
}

@end
