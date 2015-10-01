#import "TGUpdatesWithDate.h"

@implementation TGUpdatesWithDate

- (instancetype)initWithUpdates:(NSArray *)updates date:(int32_t)date users:(NSArray *)users chats:(NSArray *)chats
{
    self = [super init];
    if (self != nil)
    {
        _updates = updates;
        _date = date;
        _users = users;
        _chats = chats;
    }
    return self;
}

@end
