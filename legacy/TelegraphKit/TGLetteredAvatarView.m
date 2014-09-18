#import "TGLetteredAvatarView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGImageManager.h"
#import "TGGradientLabel.h"

@interface TGLetteredAvatarView ()
{
    TGGradientLabel *_label;
    
    UIFont *_singleFont;
    UIFont *_doubleFont;
    bool _usingSingleFont;
    bool _sameFonts;
    CGFloat _singleSize;
    CGFloat _doubleSize;
}

@end

@implementation TGLetteredAvatarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _label = [[TGGradientLabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        [self addSubview:_label];
    }
    return self;
}

- (void)setSingleFontSize:(CGFloat)singleFontSize doubleFontSize:(CGFloat)doubleFontSize useBoldFont:(bool)useBoldFont
{
    if (ABS(singleFontSize - _singleSize) < FLT_EPSILON && ABS(doubleFontSize - _doubleSize))
        return;
    
    _singleSize = singleFontSize;
    _doubleSize = doubleFontSize;
    
    _singleFont = TGUltralightSystemFontOfSize(singleFontSize);
    
    if (useBoldFont)
        _doubleFont = TGSystemFontOfSize(doubleFontSize);
    else
        _doubleFont = TGLightSystemFontOfSize(doubleFontSize);
    
    _sameFonts = ABS(singleFontSize - doubleFontSize) < DBL_EPSILON;
}

- (void)loadImage:(UIImage *)image
{
    _label.hidden = true;
    
    [super loadImage:image];
}

- (void)loadImage:(NSString *)url filter:(NSString *)filter placeholder:(UIImage *)placeholder forceFade:(bool)forceFade
{
    _label.hidden = true;
    
    [super loadImage:url filter:filter placeholder:placeholder forceFade:forceFade];
}

- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    if (!_label.hidden)
    {
        if (firstName.length != 0 && lastName.length != 0)
            _label.text = [[NSString alloc] initWithFormat:@"%@\u200D%@", [firstName substringToIndex:1], [lastName substringToIndex:1]];
        else if (firstName.length != 0)
            _label.text = [firstName substringToIndex:1];
        else if (lastName.length != 0)
            _label.text = [lastName substringToIndex:1];
        else
            _label.text = @" ";
        
        if (firstName.length != 0 && lastName.length != 0)
        {
            _label.text = [[NSString alloc] initWithFormat:@"%@\u200D%@", [firstName substringToIndex:1], [lastName substringToIndex:1]];
        }
        else if (firstName.length != 0)
        {
            _label.text = [firstName substringToIndex:1];
        }
        else if (lastName.length != 0)
        {
            _label.text = [lastName substringToIndex:1];
        }
        else
            _label.text = @" ";
        
        [_label sizeToFit];
        CGSize labelSize = _label.frame.size;
        CGSize boundsSize = self.bounds.size;
        labelSize.height = boundsSize.height;
        _label.frame = CGRectMake(TGRetinaFloor((boundsSize.width - labelSize.width) / 2.0f), CGFloor((boundsSize.height - labelSize.height) / 2.0f), labelSize.width, labelSize.height);
    }
}

- (void)setTitle:(NSString *)title
{
    _label.text = title.length >= 1 ? [title substringToIndex:1] : @" ";
    
    [_label sizeToFit];
    [self setNeedsLayout];
}

- (void)setTitleNeedsDisplay
{
    if (!_label.hidden)
        [_label setNeedsDisplay];
}

- (void)loadUserPlaceholderWithSize:(CGSize)size uid:(int)uid firstName:(NSString *)firstName lastName:(NSString *)lastName placeholder:(UIImage *)placeholder
{
    _label.font = _doubleFont;
    _usingSingleFont = false;
    
    if (firstName.length != 0 && lastName.length != 0)
    {
        _label.text = [[NSString alloc] initWithFormat:@"%@\u200D%@", [firstName substringToIndex:1], [lastName substringToIndex:1]];
    }
    else if (firstName.length != 0)
    {
        _label.text = [firstName substringToIndex:1];
    }
    else if (lastName.length != 0)
    {
        _label.text = [lastName substringToIndex:1];
    }
    else
        _label.text = @" ";
    
    _label.textColor = uid == 0 ? [UIColor whiteColor] : [UIColor whiteColor];

    [_label sizeToFit];    
    [self setNeedsLayout];
    
    NSString *placeholderUri = [[NSString alloc] initWithFormat:@"placeholder://?type=user-avatar&w=%d&h=%d&uid=%" PRId32 "", (int)size.width, (int)size.height, (int32_t)uid];
    if (!TGStringCompare([self currentUrl], placeholderUri))
        [super loadImage:placeholderUri filter:nil placeholder:placeholder];
    
    _label.hidden = false;
}

typedef struct
{
    int top;
    int bottom;
} TGGradientColors;

- (void)loadGroupPlaceholderWithSize:(CGSize)size conversationId:(int64_t)conversationId title:(NSString *)title placeholder:(UIImage *)placeholder
{
    _label.font = _singleFont;
    _usingSingleFont = true;
    
    _label.text = title.length >= 1 ? [title substringToIndex:1] : @" ";
    
    if (conversationId == 0)
        _label.textColor = [UIColor whiteColor];
    else
        _label.textColor = [UIColor whiteColor];
    
    [_label sizeToFit];
    CGSize labelSize = _label.frame.size;
    CGSize boundsSize = self.bounds.size;
    labelSize.height = boundsSize.height;
    _label.frame = CGRectMake(TGRetinaFloor((boundsSize.width - labelSize.width) / 2.0f), CGFloor((boundsSize.height - labelSize.height) / 2.0f), labelSize.width, labelSize.height);
    
    [super loadImage:[[NSString alloc] initWithFormat:@"placeholder://?type=group-avatar&w=%d&h=%d&cid=%" PRId64 "", (int)size.width, (int)size.height, conversationId] filter:nil placeholder:placeholder];
    
    _label.hidden = false;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize labelSize = _label.frame.size;
    CGSize boundsSize = self.bounds.size;
    labelSize.height = boundsSize.height;
    _label.frame = CGRectMake(TGRetinaFloor((boundsSize.width - labelSize.width) / 2.0f), CGFloor((boundsSize.height - labelSize.height) / 2.0f), labelSize.width, labelSize.height);
}

@end
