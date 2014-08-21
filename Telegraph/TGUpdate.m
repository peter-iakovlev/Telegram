#import "TGUpdate.h"

@implementation TGUpdate

- (id)initWithUpdates:(NSArray *)updates date:(int)date beginSeq:(int)beginSeq endSeq:(int)endSeq messageDate:(int)messageDate usersDesc:(NSArray *)usersDesc chatsDesc:(NSArray *)chatsDesc
{
    self = [super init];
    if (self != nil)
    {
        _updates = updates;
        _date = date;
        _beginSeq = beginSeq;
        _endSeq = endSeq;
        _messageDate = messageDate;
        _usersDesc = usersDesc;
        _chatsDesc = chatsDesc;
    }
    return self;
}

@end
