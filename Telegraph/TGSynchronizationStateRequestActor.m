#import "TGSynchronizationStateRequestActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGTelegramNetworking.h"

@implementation TGSynchronizationStateRequestActor

+ (NSString *)genericPath
{
    return @"/tg/service/synchronizationstate";
}

- (void)execute:(NSDictionary *)__unused options
{
    int state = [ActionStageInstance() requestActorStateNow:@"/tg/service/updatestate"] ? 1 : 0;
    if ([[TGTelegramNetworking instance] isUpdating])
        state |= 1;
    if ([[TGTelegramNetworking instance] isConnecting])
        state |= 2;
    if (![[TGTelegramNetworking instance] isNetworkAvailable])
        state |= 4;
    
    [ActionStageInstance() nodeRetrieved:self.path node:[[SGraphObjectNode alloc] initWithObject:[NSNumber numberWithInt:state]]];
}

@end
