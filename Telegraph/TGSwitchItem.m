#import "TGSwitchItem.h"

@implementation TGSwitchItem

@synthesize title = _title;
@synthesize isOn = _isOn;

@synthesize action = _action;

- (id)init
{
    self = [super initWithType:TGSwitchItemType];
    if (self != nil)
    {
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithType:TGSwitchItemType];
    if (self != nil)
    {
        _title = title;
    }
    return self;
}

@end
