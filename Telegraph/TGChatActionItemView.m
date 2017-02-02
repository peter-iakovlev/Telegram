#import "TGChatActionItemView.h"

@interface TGChatActionItemView ()
{
    UIView *_selectionView;
    
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UILabel *_altLabel;
    UIImageView *_arrowView;
}
@end

@implementation TGChatActionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _selectionView = [[UIView alloc] initWithFrame:self.bounds];
        _selectionView.alpha = 0.0f;
        _selectionView.backgroundColor = UIColorRGB(0xffffff);
        _selectionView.userInteractionEnabled = false;
        [self addSubview:_selectionView];
    }
    return self;
}

- (void)setItem:(TGChatActionItem *)item
{
    _titleLabel.text = item.title;
    _iconView.image = item.icon;
    
    _subtitleLabel.text = (item.subitems.firstObject != nil) ? [item.subitems.firstObject title] : @"";
    _altLabel.text = @"";
    
    _arrowView.hidden = (item.subitems.count == 0);
}

- (void)setHighlighted:(bool)highlighted animated:(bool)animated
{
    CGFloat targetAlpha = highlighted ? 1.0f : 0.0f;
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            _selectionView.alpha = targetAlpha;
        }];
    }
    else
    {
        _selectionView.alpha = targetAlpha;
    }
}

- (void)setExpanded:(bool)expanded animated:(bool)animated
{
    
}

- (void)layoutSubviews
{
    _selectionView.frame = self.bounds;
}

@end
