#import "TGWidgetUserCell.h"
#import "TGWidgetUser.h"

#import "TGWidgetImageView.h"

NSString *const TGWidgetUserCellIdentifier = @"TGWidgetUserCell";
const CGSize TGWidgetUserCellSize = { 76.0f, 76.0f };

@interface TGWidgetUserCell ()
{
    TGWidgetImageView *_imageView;
    UILabel *_nameLabel;
    
    UIVisualEffectView *_effectView;
}
@end

@implementation TGWidgetUserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _imageView = [[TGWidgetImageView alloc] initWithFrame:CGRectMake(10.0f, 0, 56.0f, 56.0f)];
        _imageView.clipsToBounds = true;
        _imageView.layer.cornerRadius = 28.0f;
        [self addSubview:_imageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:12.0f];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)setUser:(TGWidgetUser *)user avatarSignal:(SSignal *)avatarSignal effectView:(UIVisualEffectView *)effectView
{
    _effectView = effectView;
    
    if (_nameLabel.superview != _effectView.contentView)
        [_effectView.contentView addSubview:_nameLabel];
    
    [_imageView setSignal:avatarSignal];

    _nameLabel.text = user.firstName.length > 0 ? user.firstName : user.lastName;
    [_nameLabel sizeToFit];
}

- (void)setHidden:(bool)hidden animated:(bool)animated
{
    void (^changeBlock)(void) = ^
    {
        self.alpha = hidden ? 0.0f : 1.0f;
    };
    
    NSTimeInterval delay = hidden ? 0.0 : 0.05;
    if (animated)
        [UIView animateWithDuration:0.3 delay:delay options:kNilOptions animations:changeBlock completion:nil];
    else
        changeBlock();
}

- (void)layoutSubviews
{
    CGRect nameFrame = CGRectMake(0, 60.0f, self.frame.size.width, ceil(_nameLabel.frame.size.height));
    _nameLabel.frame = [self convertRect:nameFrame toView:_effectView];
}

@end
