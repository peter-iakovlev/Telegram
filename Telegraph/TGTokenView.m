#import "TGTokenView.h"

#import "TGFont.h"

static UIImage *tokenBackgroundImage()
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"TokenBackground.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

static UIImage *tokenBackgroundHighlightedImage()
{
    static UIImage *image = nil;
    if (image == nil)
    {
        UIImage *rawImage = [UIImage imageNamed:@"TokenBackground_Highlighted.png"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    return image;
}

@implementation TGTokenView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self setBackgroundImage:tokenBackgroundImage() forState:UIControlStateNormal];
    [self setBackgroundImage:tokenBackgroundHighlightedImage() forState:UIControlStateHighlighted];
    [self setBackgroundImage:tokenBackgroundHighlightedImage() forState:UIControlStateSelected];
    [self setBackgroundImage:tokenBackgroundHighlightedImage() forState:UIControlStateHighlighted | UIControlStateSelected];
    
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:nil forState:UIControlStateNormal];
    
    UIColor *highlightedTextColor = [UIColor whiteColor];
    
    [self setTitleColor:highlightedTextColor forState:UIControlStateHighlighted];
    [self setTitleColor:highlightedTextColor forState:UIControlStateSelected];
    [self setTitleColor:highlightedTextColor forState:UIControlStateHighlighted | UIControlStateSelected];
    
    [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchDown];
}

- (void)buttonPressed
{
    [self becomeFirstResponder];
}

- (void)setLabel:(NSString *)label
{
    _label = label;
    
    [self setTitle:label forState:UIControlStateNormal];
    
    _preferredWidth = [label sizeWithFont:self.titleLabel.font].width + 10;
}

- (CGFloat)preferredWidth
{
    return MAX(_preferredWidth, 10);
}

#pragma mark -

- (BOOL)becomeFirstResponder
{
    if ([super becomeFirstResponder])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([self.superview.superview respondsToSelector:@selector(highlightToken:)])
            [self.superview.superview performSelector:@selector(highlightToken:) withObject:self];
#pragma clang diagnostic pop
        return true;
    }
    
    return false;
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([self.superview.superview respondsToSelector:@selector(unhighlightToken:)])
            [self.superview.superview performSelector:@selector(unhighlightToken:) withObject:self];
#pragma clang diagnostic pop
        return true;
    }
    
    return false;
}

- (void)deleteBackward
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self.superview.superview respondsToSelector:@selector(deleteToken:)])
        [self.superview.superview performSelector:@selector(deleteToken:) withObject:self];
#pragma clang diagnostic pop
}

- (BOOL)hasText
{
    return false;
}

- (void)insertText:(NSString *)__unused text
{
}

- (BOOL)canBecomeFirstResponder
{
    return true;
}

@end
