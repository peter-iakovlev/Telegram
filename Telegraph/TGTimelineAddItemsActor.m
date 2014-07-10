#import "TGTimelineAddItemsActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

@implementation TGTimelineAddItemsActor

- (void)prepare:(NSDictionary *)options
{
    int timelineId = [[options objectForKey:@"timelineId"] intValue];
    self.requestQueueName = [NSString stringWithFormat:@"timeline/%d", timelineId];
}

- (void)execute:(NSDictionary *)options
{
    int timelineId = [[options objectForKey:@"timelineId"] intValue];
    NSArray *items = [options objectForKey:@"items"];
    if (items == nil || items.count == 0)
        [ActionStageInstance() actionCompleted:self.path result:nil];
    
    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/timeline/(%d)/items", timelineId] resource:[[SGraphObjectNode alloc] initWithObject:items]];
}

@end
