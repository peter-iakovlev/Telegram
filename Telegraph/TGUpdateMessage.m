#import "TGUpdateMessage.h"

@implementation TGUpdateMessage

@synthesize message = _message;
@synthesize messageDate = _messageDate;

- (id)initWithMessage:(id)message messageDate:(int)messageDate
{
    self = [super init];
    if (self != nil)
    {
        _message = message;
        _messageDate = messageDate;
    }
    return self;
}

@end
