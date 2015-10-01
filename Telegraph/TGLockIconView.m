#import "TGLockIconView.h"

@interface TGLockIconView ()
{
    bool _isLocked;
    
    UIImageView *_topView;
    UIImageView *_bottomView;
}

@end

@implementation TGLockIconView

- (UIImage *)topLockedImage
{
    return [UIImage imageNamed:@"ChatListLock_LockedTop.png"];
}

- (UIImage *)topUnlockedImage
{
    return [UIImage imageNamed:@"ChatListLock_UnlockedTop.png"];
}

- (UIImage *)bottomLockedImage
{
    return [UIImage imageNamed:@"ChatListLock_LockedBottom.png"];
}

- (UIImage *)bottomUnlockedImage
{
    return [UIImage imageNamed:@"ChatListLock_UnlockedBottom.png"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _topView = [[UIImageView alloc] init];
        [self addSubview:_topView];
        _bottomView = [[UIImageView alloc] init];
        [self addSubview:_bottomView];
    }
    return self;
}

- (bool)isLocked
{
    return _isLocked;
}

- (void)setIsLocked:(bool)isLocked animated:(bool)animated
{
    _isLocked = isLocked;
    if (animated)
    {
        UIImageView *topViewCopy = [[UIImageView alloc] initWithImage:_topView.image];
        topViewCopy.frame = _topView.frame;
        [self addSubview:topViewCopy];
        
        UIImageView *bottomViewCopy = [[UIImageView alloc] initWithImage:_bottomView.image];
        bottomViewCopy.frame = _bottomView.frame;
        [self addSubview:bottomViewCopy];
        
        _topView.image = _isLocked ? [self topLockedImage] : [self topUnlockedImage];
        _bottomView.image = _isLocked ? [self bottomLockedImage] : [self bottomUnlockedImage];
        
        _topView.alpha = 0.5f;
        _bottomView.alpha = 0.5f;
        
        dispatch_block_t block = ^
        {
            [self layoutItems];
            topViewCopy.frame = _topView.frame;
            bottomViewCopy.frame = _bottomView.frame;
        };
        
        [UIView animateWithDuration:0.1 animations:^
        {
            topViewCopy.alpha = 0.0f;
            bottomViewCopy.alpha = 0.0f;
            
            _topView.alpha = 1.0f;
            _bottomView.alpha = 1.0f;
        }];
        
        if (iosMajorVersion() >= 7)
        {
            [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.39f initialSpringVelocity:0.0f options:0 animations:^
            {
                block();
            } completion:^(__unused BOOL finished)
            {
                [topViewCopy removeFromSuperview];
                [bottomViewCopy removeFromSuperview];
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^
            {
                block();
            } completion:^(__unused BOOL finished)
            {
                [topViewCopy removeFromSuperview];
                [bottomViewCopy removeFromSuperview];
            }];
        }
    }
    else
    {
        _topView.image = _isLocked ? [self topLockedImage] : [self topUnlockedImage];
        _bottomView.image = _isLocked ? [self bottomLockedImage] : [self bottomUnlockedImage];
        [self layoutItems];
    }
}

- (void)layoutItems
{
    if (_isLocked)
    {
        _topView.frame = CGRectMake((10.0f - 7.0f) / 2.0f, 0.0f, 7.0f, 5.0f);
        _bottomView.frame = CGRectMake(0.0f, 5.0f, 10.0f, 7.0f);
    }
    else
    {
        _topView.frame = CGRectMake(6.0f, 0.0f, 7.0f, 5.0f);
        _bottomView.frame = CGRectMake(0.0f, 5.0f, 10.0f, 7.0f);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
