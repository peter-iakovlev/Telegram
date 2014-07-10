#import "TGTimelineRemoveItemsRequestActor.h"

#import "TGTelegraph.h"

@implementation TGTimelineRemoveItemsRequestActor

+ (NSString *)genericPath
{
    return @"/tg/timeline/@/removeItems/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        NSRange range = [self.path rangeOfString:@")/removeItems/"];
        int timelineId = [[self.path substringWithRange:NSMakeRange(14, range.location - 14)] intValue];
        self.requestQueueName = [NSString stringWithFormat:@"timeline/%d", timelineId];
    }
    return self;
}

- (void)execute:(NSDictionary *)__unused options
{
    TGLog(@"Method currently unsupported");
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)removeTimelineItemsSuccess
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)removeTimelineItemsFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

@end
