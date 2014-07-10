#import "TGButtonMenuItem.h"

@implementation TGButtonMenuItem

@synthesize title = _title;
@synthesize subtype = _subtype;
@synthesize action = _action;
@synthesize enabled = _enabled;

- (id)init
{
    self = [super initWithType:TGButtonMenuItemType];
    if (self != nil)
    {
        _enabled = true;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title subtype:(TGButtonMenuItemSubtype)subtype
{
    self = [super initWithType:TGButtonMenuItemType];
    if (self != nil)
    {
        _title = title;
        _subtype = subtype;
        _enabled = true;
    }
    return self;
}

@end
