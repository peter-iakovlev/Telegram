#import "TGNotificationException.h"

@implementation TGNotificationException

- (instancetype)initWithPeerId:(int64_t)peerId notificationType:(NSNumber *)notificationType muteUntil:(NSNumber *)muteUntil
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _notificationType = notificationType;
        _muteUntil = muteUntil;
    }
    return self;
}

@end
