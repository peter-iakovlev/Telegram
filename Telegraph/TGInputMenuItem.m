#import "TGInputMenuItem.h"

@implementation TGInputMenuItem

@synthesize label = _label;
@synthesize text = _text;
@synthesize textChangedAction = _textChangedAction;

- (id)initWithLabel:(NSString *)label text:(NSString *)text
{
    self = [super initWithType:TGInputMenuItemType];
    if (self != nil)
    {
        _label = label;
        _text = text;
    }
    return self;
}

@end
