#import "TGMenuItem.h"

@implementation TGMenuItem

@synthesize type = _type;
@synthesize tag = _tag;

- (id)initWithType:(int)type
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
    }
    return self;
}

@end
