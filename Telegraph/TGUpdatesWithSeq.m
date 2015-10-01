#import "TGUpdatesWithSeq.h"

@implementation TGUpdatesWithSeq

- (instancetype)initWithUpdates:(NSArray *)updates date:(int32_t)date seqStart:(int32_t)seqStart seqEnd:(int32_t)seqEnd users:(NSArray *)users chats:(NSArray *)chats
{
    self = [super init];
    if (self != nil)
    {
        _updates = updates;
        _date = date;
        _seqStart = seqStart;
        _seqEnd = seqEnd;
        _users = users;
        _chats = chats;
    }
    return self;
}

@end
