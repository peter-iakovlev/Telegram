#import "TGModernButtonView.h"

@interface TGModernButtonView ()
{
    long _backgroundImageFingerprint;
    long _highightedBackgroundImageFingerprint;
    
    NSString *_title;
    NSArray *_possibleTitles;
    long _titleFontFingerprint;
    
    long _imageFingerprint;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.adjustsImageWhenDisabled = false;
        self.adjustsImageWhenHighlighted = false;
    }
    return self;
}

- (void)willBecomeRecycled
{
}

- (NSString *)viewStateIdentifier
{
    if (_viewStateIdentifier)
    {
    }
    
    return [[NSString alloc] initWithFormat:@"TGModernButtonView/%lx/%lx/%@/%lx/%lx", _backgroundImageFingerprint, _highightedBackgroundImageFingerprint, _title, (long)_titleFontFingerprint, (long)_imageFingerprint];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImageFingerprint = (long)backgroundImage;
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
}

- (void)setHighlightedBackgroundImage:(UIImage *)highlightedBackgroundImage
{
    _highightedBackgroundImageFingerprint = (long)highlightedBackgroundImage;
    [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setTitle:title forState:UIControlStateNormal];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFontFingerprint = (long)titleFont;
    self.titleLabel.font = titleFont;
}

- (void)setImage:(UIImage *)image
{
    _imageFingerprint = (long)image;
    [self setImage:image forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
