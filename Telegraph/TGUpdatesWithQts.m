#import "TGUpdatesWithQts.h"

@implementation TGUpdatesWithQts

- (instancetype)initWithUpdates:(NSArray *)updates users:(NSArray *)users chats:(NSArray *)chats
{
    self = [super init];
    if (self != nil)
    {
        _updates = updates;
        _users = users;
        _chats = chats;
    }
    return self;
}

@end
