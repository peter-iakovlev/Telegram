#import "TGAttachmentSheetRecentControlledButtonItemView.h"

@interface TGAttachmentSheetRecentControlledButtonItemView ()
{
    bool _alternate;
    NSString *_title;
}

@end

@implementation TGAttachmentSheetRecentControlledButtonItemView

- (instancetype)initWithTitle:(NSString *)title pressed:(void (^)())pressed alternatePressed:(void (^)())alternatePressed
{
    self = [super initWithTitle:title pressed:pressed];
    if (self != nil)
    {
        _title = title;
        _alternatePressed = [alternatePressed copy];
    }
    return self;
}

- (void)setAlternateWithTitle:(NSString *)title
{
    _alternate = true;
    [self setTitle:title];
    [self setBold:true];
}

- (void)setDefault
{
    _alternate = false;
    [self setTitle:_title];
    [self setBold:false];
}

- (void)_buttonPressed
{
    if (!_alternate)
    {
        if (self.pressed)
            self.pressed();
    }
    else
    {
        if (_alternatePressed)
            _alternatePressed();
    }
}

@end
