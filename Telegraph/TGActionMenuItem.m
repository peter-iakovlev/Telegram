#import "TGActionMenuItem.h"

@implementation TGActionMenuItem

@synthesize title = _title;

@synthesize action = _action;

- (id)init
{
    self = [super initWithType:TGActionMenuItemType];
    if (self != nil)
    {
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithType:TGActionMenuItemType];
    if (self != nil)
    {
        _title = title;
    }
    return self;
}

@end
