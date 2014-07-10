#import "TGUserNode.h"

@implementation TGUserNode

@synthesize user = _user;

- (id)initWithUser:(TGUser *)user
{
    self = [super init];
    if (self != nil)
    {
        _user = user;
    }
    return self;
}

@end
