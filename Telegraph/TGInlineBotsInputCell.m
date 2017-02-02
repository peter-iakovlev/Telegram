#import "TGInlineBotsInputCell.h"

#import "TGLetteredAvatarView.h"
#import "TGUser.h"

@interface TGInlineBotsInputCell () {
    TGLetteredAvatarView *_avatarView;
    UIImageView *_selectionView;
    bool _focused;
}

@end

@implementation TGInlineBotsInputCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _avatarView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake((52.0f - 30.0f) / 2.0f, 8.0f, 30.0f, 30.0f)];
        [_avatarView setSingleFontSize:12.0f doubleFontSize:12.0f useBoldFont:false];
        [self.contentView addSubview:_avatarView];
        
        static UIImage *selectionImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(33.0f, 33.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetBlendMode(context, kCGBlendModeCopy);
            CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 33.0f, 33.0f));
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(1.5f, 1.5f, 30.0f, 30.0f));
            
            selectionImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        _selectionView = [[UIImageView alloc] initWithImage:selectionImage];
        _selectionView.center = _avatarView.center;
        _selectionView.hidden = true;
        [self.contentView addSubview:_selectionView];
        
        [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _avatarView.transform = CGAffineTransformIdentity;
    _avatarView.alpha = 1.0f;
    _focused = false;
    _selectionView.hidden = true;
    _selectionView.transform = CGAffineTransformIdentity;
    _selectionView.alpha = 1.0f;
}

- (void)setUser:(TGUser *)user {
    if (_user != user) {
        _user = user;
        
        CGSize size = CGSizeMake(30.0f, 30.0f);
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            //!placeholder
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
            CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
            CGContextSetLineWidth(context, 1.0f);
            CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, size.width - 1.0f, size.height - 1.0f));
            
            placeholder = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        if (user.photoUrlSmall.length != 0) {
            [_avatarView loadImage:user.photoUrlSmall filter:@"circle:30x30" placeholder:placeholder];
        } else {
            [_avatarView loadUserPlaceholderWithSize:size uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
        }
    }
}

- (void)animateIn {
    if (iosMajorVersion() >= 8) {
        _avatarView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0 options:0 animations:^{
            _avatarView.transform = _focused ? CGAffineTransformMakeScale(0.9f, 0.9f) : CGAffineTransformIdentity;
        } completion:nil];
        
        _selectionView.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
        _selectionView.alpha = 0.0f;
        [UIView animateWithDuration:0.16 delay:0.115 options:0 animations:^{
            _selectionView.transform = CGAffineTransformIdentity;
            _selectionView.alpha = 1.0f;
        } completion:nil];
    } else {
        
    }
}

- (void)animateOut {
    if (iosMajorVersion() >= 8) {
        [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^{
            _avatarView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
            _avatarView.alpha = 0.0f;
        } completion:nil];
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0 options:0 animations:^{
            _selectionView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            _selectionView.alpha = 0.0f;
        } completion:nil];
    } else {
        
    }
}

- (void)setFocused:(bool)focused animated:(bool)animated {
    if (_focused != focused) {
        _focused = focused;
        
        if (animated) {
            if (focused) {
                _selectionView.hidden = false;
                _selectionView.alpha = 0.0f;
            } else {
                
            }
            [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
                _avatarView.transform = focused ? CGAffineTransformMakeScale(0.9f, 0.9f) : CGAffineTransformIdentity;
                _selectionView.alpha = focused ? 1.0f : 0.0f;
            } completion:^(BOOL finished) {
                if (finished) {
                    _selectionView.hidden = !focused;
                }
            }];
        } else {
            _selectionView.hidden = !focused;
            _avatarView.transform = focused ? CGAffineTransformMakeScale(0.9f, 0.9f) : CGAffineTransformIdentity;
            _selectionView.alpha = 1.0f;
        }
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_tapped && _user != nil) {
            _tapped(_user);
        }
    }
}

@end
