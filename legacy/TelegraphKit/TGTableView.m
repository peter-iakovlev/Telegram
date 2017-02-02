#import "TGTableView.h"

#import <objc/runtime.h>

@interface TGTableView ()

@property (nonatomic) bool reversed;

@end

@implementation TGTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style reversed:(bool)reversed
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        _reversed = reversed;
        _scrollInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)__unused view
{
    return true;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(touchedTableBackground)])
        [self.delegate performSelector:@selector(touchedTableBackground)];
#pragma clang diagnostic pop
}

- (void)setScrollInsets:(UIEdgeInsets)scrollInsets
{
    _scrollInsets = scrollInsets;
    if (_reversed)
        self.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, _scrollInsets.bottom, self.bounds.size.width - _scrollInsets.right);
    else
        self.scrollIndicatorInsets = _scrollInsets;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_reversed)
        self.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, _scrollInsets.bottom, self.bounds.size.width - _scrollInsets.right);
    else
        self.scrollIndicatorInsets = _scrollInsets;
    
    if (_didLayoutBlock)
        _didLayoutBlock(self);
}

@end
