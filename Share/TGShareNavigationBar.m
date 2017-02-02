#import "TGShareNavigationBar.h"

#import <LegacyDatabase/LegacyDatabase.h>

@interface TGShareNavigationBar ()
{
    UIView *_backView;
}
@end

@implementation TGShareNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _backView = [[UIView alloc] initWithFrame:self.bounds];
        _backView.backgroundColor = TGColorWithHex(0xf7f7f7);
        [self addSubview:_backView];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (point.x > 0 && point.x < self.bounds.size.width && point.y > -20 && point.y < self.bounds.size.height)
        return true;
    
    return false;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _backView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y - 20.0f, self.bounds.size.width, self.bounds.size.height + 20.0f);
    [self insertSubview:_backView atIndex:1];
}

@end
