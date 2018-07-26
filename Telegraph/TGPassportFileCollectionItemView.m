#import "TGPassportFileCollectionItemView.h"

#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGMessageImageViewOverlayView.h>
#import "TransformImageView.h"

#import "TGPresentation.h"

#import "TGSimpleImageView.h"

@interface TGPassportFileCollectionItemView ()
{
    UIView *_backView;
    TransformImageView *_imageView;
    UIImage *_icon;
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    TGMessageImageViewOverlayView *_progressView;
    
    SMetaDisposable *_progressDisposable;
    
    CGSize _calculatedSize;
    
    CGSize _imageSize;
    bool _isRequired;
}
@end

@implementation TGPassportFileCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.separatorInset = 90.0f;
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 44.0f)];
        _backView.clipsToBounds = true;
        _backView.layer.cornerRadius = 6.0f;
        _backView.hidden = true;
        [self.editingContentView addSubview:_backView];
        
        __weak TGPassportFileCollectionItemView *weakSelf = self;
        _imageView = [[TransformImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 44.0f)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageView setArguments:[[TransformImageArguments alloc] initAutoSizeWithBoundingSize:CGSizeMake(60.0f, 44.0f) cornerRadius:6.0f]];
        _imageView.imageUpdated = ^
        {
            __strong TGPassportFileCollectionItemView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_imageSize = strongSelf->_imageView.imageSize;
                [strongSelf setNeedsLayout];
            }
        };
        [self.editingContentView addSubview:_imageView];
        
        _progressView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [_progressView setRadius:32.0f];
        [_progressView setNone];
        _progressView.userInteractionEnabled = false;
        [self.editingContentView addSubview:_progressView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        [self.editingContentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.font = TGSystemFontOfSize(14);
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.editingContentView addSubview:_subtitleLabel];
    }
    return self;
}

- (void)dealloc
{
    [_progressDisposable dispose];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    _titleLabel.textColor = presentation.pallete.collectionMenuTextColor;
    _subtitleLabel.textColor = _isRequired ? presentation.pallete.collectionMenuDestructiveColor : presentation.pallete.collectionMenuVariantColor;
    _backView.backgroundColor = [presentation.pallete.collectionMenuVariantColor colorWithAlphaComponent:0.15f];
    
    if (_icon != nil)
        _iconView.image = TGTintedImage(_icon, self.presentation.pallete.collectionMenuAccentColor);
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitleLabel.text = subtitle;
}

- (void)setIcon:(UIImage *)icon
{
    if (_iconView == nil)
    {
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeCenter;
        [self.editingContentView addSubview:_iconView];
    }
    
    _icon = icon;
    if (_icon != nil)
        _iconView.image = TGTintedImage(_icon, self.presentation.pallete.collectionMenuAccentColor);
    else
        _iconView.image = nil;
}

- (void)setImageSignal:(SSignal *)signal
{
    [_imageView setSignal:signal];
    if (signal == nil)
    {
        [_imageView reset];
        _iconView.hidden = false;
        if (_iconView != nil)
            _backView.hidden = true;
    }
    else
    {
        _iconView.hidden = true;
        if (_iconView != nil)
            _backView.hidden = false;
    }
}

- (void)setIsRequired:(bool)isRequired
{
    _isRequired = isRequired;
    _subtitleLabel.textColor = isRequired ? self.presentation.pallete.collectionMenuDestructiveColor : self.presentation.pallete.collectionMenuVariantColor;
}

- (void)setImageViewHidden:(bool)hidden
{
    _imageView.hidden = hidden;
}

- (void)setProgressSignal:(SSignal *)progressSignal
{
    if (_progressDisposable == nil)
        _progressDisposable = [[SMetaDisposable alloc] init];
    
    __weak TGPassportFileCollectionItemView *weakSelf = self;
    [_progressDisposable setDisposable:[[progressSignal deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGPassportFileCollectionItemView *strongSelf = weakSelf;
        if ([next isKindOfClass:[NSNumber class]])
            [strongSelf->_progressView setProgress:[next floatValue] cancelEnabled:false animated:true];
        else
            [strongSelf->_progressView setNone];
    }]];
}

- (void)setProgress:(CGFloat)progress hidden:(bool)hidden
{
    _progressView.hidden = hidden;
    
    if (hidden)
        [_progressView setNone];
    else
        [_progressView setProgress:progress cancelEnabled:false animated:true];
}

- (void)deleteAction
{
    [super deleteAction];
    
    if (_removeRequested)
        _removeRequested();
}

- (CGSize)imageSize
{
    return _imageSize;
}

- (UIView *)imageView
{
    return _imageView;
}

- (void)setCalculatedSize:(CGSize)calculatedSize
{
    _calculatedSize = calculatedSize;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGSize imageSize = TGScaleToFit(_imageSize, CGSizeMake(60, 44));
    
    _iconView.frame = CGRectMake(15.0f, 1.0f, 62.0f, 62.0f);
    _imageView.frame = CGRectMake(15.0f + 30.0f - imageSize.width / 2.0f + self.safeAreaInset.left, 10.0f + 22.0f - imageSize.height / 2.0f, imageSize.width, imageSize.height);
    _backView.frame = CGRectMake(15.0f + self.safeAreaInset.left, 10.0f, 60.0f, 44.0f);
    _backView.alpha = fabs(_imageView.frame.size.width - 60) < FLT_EPSILON ? 0.0f : 1.0f;
    _titleLabel.frame = CGRectMake(90.0f + self.safeAreaInset.left, 9.0f, bounds.size.width - 15 - 90, 26);
    _subtitleLabel.frame = CGRectMake(90.0f + self.safeAreaInset.left, CGRectGetMaxY(_titleLabel.frame) + 2.0f, _calculatedSize.width, _calculatedSize.height);
    _progressView.center = CGPointMake(_imageView.center.x, _imageView.center.y);
}

@end
