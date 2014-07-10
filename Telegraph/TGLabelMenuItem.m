#import "TGLabelMenuItem.h"

@implementation TGLabelMenuItem

@synthesize label = _label;
@synthesize title = _title;
@synthesize color = _color;

- (id)initWithLabel:(NSString *)label
{
    self = [super initWithType:TGLabelMenuItemType];
    if (self != nil)
    {
        _label = label;
    }
    return self;
}

@end
