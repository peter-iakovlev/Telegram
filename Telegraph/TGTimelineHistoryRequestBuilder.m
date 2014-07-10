#import "TGTimelineHistoryRequestBuilder.h"

#import "TGUserDataRequestBuilder.h"

#import "ActionStage.h"
#import "SGraphListNode.h"

#import "TGTelegraph.h"

#import "TGTimelineItem.h"

@implementation TGTimelineHistoryRequestBuilder

+ (NSString *)genericPath
{
    return @"/tg/timeline/@/items/@";
}

- (void)prepare:(NSDictionary *)options
{
    int timelineId = [[options objectForKey:@"timelineId"] intValue];
    self.requestQueueName = [NSString stringWithFormat:@"timeline/%d", timelineId];
}

- (void)execute:(NSDictionary *)options
{
    int timelineId = [[options objectForKey:@"timelineId"] intValue];
    int64_t maxItemId = [[options objectForKey:@"minItemId"] longLongValue];
    
    self.cancelToken = [TGTelegraphInstance doRequestTimeline:timelineId maxItemId:maxItemId limit:20 actor:self];
}

- (void)cancel
{
    if (self.cancelToken != nil)
    {
        [TGTelegraphInstance cancelRequestByToken:self.cancelToken];
    }
    else
    {
        TGLog(@"Warning: TGTimelineHistoryRequestBuilder::cancel: cancelToken is nil");
    }
    
    [super cancel];
}

- (void)timelineHistoryRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

- (void)timelineHistoryRequestSuccess:(TLphotos_Photos *)photos
{
    [TGUserDataRequestBuilder executeUserDataUpdate:photos.users];
    
    NSMutableArray *timelineItems = [[NSMutableArray alloc] init];
    
    for (TLPhoto *photoDesc in photos.photos)
    {
        if (![photoDesc isKindOfClass:[TLPhoto$photoEmpty class]])
        {
            TGTimelineItem *item = [[TGTimelineItem alloc] initWithDescription:photoDesc];
            if (item != nil)
                [timelineItems addObject:item];
        }
    }
    
    SGraphListNode *timelineNode = [[SGraphListNode alloc] initWithItems:timelineItems];
    [ActionStageInstance() nodeRetrieved:self.path node:timelineNode];
}

@end
