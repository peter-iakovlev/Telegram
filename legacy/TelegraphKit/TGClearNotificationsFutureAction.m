#import "TGClearNotificationsFutureAction.h"

@implementation TGClearNotificationsFutureAction

- (id)init
{
    self = [super initWithType:TGClearNotificationsFutureActionType];
    if (self != nil)
    {
        self.uniqueId = 0;
    }
    return self;
}

- (NSData *)serialize
{
    return [[NSData alloc] init];
}

- (TGFutureAction *)deserialize:(NSData *)__unused data
{
    return [[TGClearNotificationsFutureAction alloc] init];
}

@end
