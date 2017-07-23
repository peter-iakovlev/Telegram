#import "TGShareCommentView.h"
#import "TGModernButton.h"
#import "TGFont.h"
#import "HPTextViewInternal.h"

@interface TGShareCommentView () <UITextViewDelegate>
{
    UIImageView *_backgroundView;
    UILabel *_placeholderView;
    CGFloat _currentHeight;
    
    TGModernButton *_clearButton;
}
@end

@implementation TGShareCommentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        UIImage *backgroundImage = nil;
        CGFloat diameter = 10.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGB(0xededed).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
        backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
        UIGraphicsEndImageContext();
        
        _backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:_backgroundView];
        
        _placeholderView = [[UILabel alloc] init];
        _placeholderView.backgroundColor = [UIColor clearColor];
        _placeholderView.textColor = UIColorRGB(0x939398);
        _placeholderView.text = TGLocalized(@"ShareMenu.Comment");
        _placeholderView.font = TGSystemFontOfSize(15.0f);
        _placeholderView.userInteractionEnabled = false;
        [_placeholderView sizeToFit];
        [self addSubview:_placeholderView];
        
        _textView = [[HPTextViewInternal alloc] init];
        _textView.font = _placeholderView.font;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor blackColor];
        _textView.scrollEnabled = false;
        ((HPTextViewInternal *)_textView).enableFirstResponder = true;
        if (iosMajorVersion() >= 7) {
            _textView.contentInset = UIEdgeInsetsZero;
            _textView.textContainerInset = [self insets];
        } else {
            _textView.contentInset = [self insets];
        }
        _textView.delegate = self;
        
        _maxHeight = [self heightForText:@" \n\n " width:100.0f];
        
        [self addSubview:_textView];
        
        _clearButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _clearButton.adjustsImageWhenHighlighted = false;
        _clearButton.hidden = true;
        [_clearButton setImage:[UIImage imageNamed:@"ShareCommentCloseIcon"] forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_clearButton];
    }
    return self;
}

- (NSString *)placeholder
{
    return _placeholderView.text;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholderView.text = placeholder;
    [_placeholderView sizeToFit];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat textHeight = [self heightForText:_textView.text width:self.frame.size.width - _clearButton.frame.size.width];
    CGFloat completeTextHeight = textHeight;
    _textView.scrollEnabled = textHeight > _maxHeight;
    textHeight = MIN(_maxHeight, textHeight);
    
    if (ABS(_currentHeight - textHeight) > FLT_EPSILON)
    {
        _currentHeight = textHeight;
        CGRect frame = self.frame;
        frame.size.height = MAX(40.0f, _currentHeight);
        self.frame = frame;
        
        if (_heightChanged != nil)
            _heightChanged(textHeight);
    }
    
    _backgroundView.frame = self.bounds;
  
    if (_textView.isFirstResponder)
    {
        _placeholderView.frame = CGRectMake(10.0f, CGFloor((40.0f - _placeholderView.frame.size.height) / 2.0f), _placeholderView.frame.size.width, _placeholderView.frame.size.height);
    }
    else
    {
        _placeholderView.frame = CGRectMake(CGFloor((self.frame.size.width - _placeholderView.frame.size.width) / 2.0f), CGFloor((40.0f - _placeholderView.frame.size.height) / 2.0f), _placeholderView.frame.size.width, _placeholderView.frame.size.height);
    }
    
    _clearButton.frame = CGRectMake(self.frame.size.width - _clearButton.frame.size.width, 5, _clearButton.frame.size.width, _clearButton.frame.size.height);
    
    CGRect textViewFrame = self.bounds;
    textViewFrame.size.width -= _clearButton.frame.size.width;
    _textView.frame = textViewFrame;
    
    _textView.contentOffset = CGPointMake(0.0f, completeTextHeight - _textView.bounds.size.height);
}

- (void)clearButtonPressed
{
    if (_textView.text.length == 0)
    {
        [_textView resignFirstResponder];
    }
    else
    {
        _textView.text = @"";
        [self textViewDidChange:_textView];
    }
}

- (void)updateClearButton
{
    if (_textView.isFirstResponder)
    {
        _clearButton.hidden = false;
        if (_textView.text.length == 0)
            [_clearButton setImage:[UIImage imageNamed:@"ShareCommentCloseIcon"] forState:UIControlStateNormal];
        else
            [_clearButton setImage:[UIImage imageNamed:@"SearchBarClearIcon"] forState:UIControlStateNormal];
    }
    else
    {
        _clearButton.hidden = true;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)__unused textView
{
    if (self.didBeginEditing != nil)
        self.didBeginEditing();
    
    [self updateClearButton];
    
    UIViewAnimationOptions options = kNilOptions;
    if (iosMajorVersion() > 7)
        options = (7 << 16);
    
    [UIView animateWithDuration:0.2f delay:0.0 options:options animations:^
    {
        [self layoutSubviews];
    } completion:nil];
}

- (void)textViewDidEndEditing:(UITextView *)__unused textView
{
    [self updateClearButton];
    
    UIViewAnimationOptions options = kNilOptions;
    if (iosMajorVersion() > 7)
        options = (7 << 16);
    
    [UIView animateWithDuration:0.2f delay:0.0 options:options animations:^
    {
        [self layoutSubviews];
    } completion:nil];
}

- (void)textViewDidChange:(UITextView *)__unused textView
{
    _placeholderView.hidden = _textView.text.length != 0;
    [self updateClearButton];
    
    [self setNeedsLayout];
}

- (UIEdgeInsets)insets
{
    return UIEdgeInsetsMake(11.0f, 5.0f, 11.0f, 5.0f);
}

- (CGFloat)heightForText:(NSString *)text width:(CGFloat)width
{
    UIEdgeInsets insets = [self insets];
    return CGCeil([text.length == 0 ? @" " : text sizeWithFont:_textView.font constrainedToSize:CGSizeMake(width - insets.left - insets.right - 10.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + insets.top + insets.bottom);
}

- (NSString *)text
{
    return _textView.text;
}

@end
