#import "TGGroupInvitationInfo.h"

@implementation TGGroupInvitationInfo

- (instancetype)initWithTitle:(NSString *)title alreadyAccepted:(bool)alreadyAccepted left:(bool)left isChannel:(bool)isChannel
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _alreadyAccepted = alreadyAccepted;
        _left = left;
        _isChannel = isChannel;
    }
    return self;
}

@end
