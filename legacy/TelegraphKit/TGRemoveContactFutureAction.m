#import "TGRemoveContactFutureAction.h"

@implementation TGRemoveContactFutureAction

- (id)initWithUid:(int)uid
{
    self = [super initWithType:TGRemoveContactFutureActionType];
    if (self != nil)
    {
        self.uniqueId = uid;
    }
    return self;
}

- (int)uid
{
    return (int)self.uniqueId;
}

- (NSData *)serialize
{
    return [NSData data];
}

- (TGFutureAction *)deserialize:(NSData *)__unused data
{
    return [[TGRemoveContactFutureAction alloc] initWithUid:0];
}

@end
