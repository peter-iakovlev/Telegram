#import "TGShareSheetSharePeersCaptionView.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGShareSheetSharePeersCaptionView () <UITextViewDelegate> {
    UIImageView *_backgroundView;
    UILabel *_placeholderView;
    UITextView *_textView;
    CGFloat _currentHeight;
    CGFloat _maxHeight;
}

@end

@implementation TGShareSheetSharePeersCaptionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
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
        _placeholderView.text = TGLocalized(@"ShareMenu.AddCaption");
        _placeholderView.font = TGSystemFontOfSize(15.0f);
        _placeholderView.userInteractionEnabled = false;
        [_placeholderView sizeToFit];
        [self addSubview:_placeholderView];
        
        _textView = [[UITextView alloc] init];
        _textView.font = _placeholderView.font;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor blackColor];
        _textView.scrollEnabled = false;
        if (iosMajorVersion() >= 7) {
            _textView.contentInset = UIEdgeInsetsZero;
            _textView.textContainerInset = [self insets];
        } else {
            _textView.contentInset = [self insets];
        }
        _textView.delegate = self;
        
        _maxHeight = [self heightForText:@" \n " width:100.0f];
        
        [self addSubview:_textView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat textHeight = [self heightForText:_textView.text width:self.frame.size.width];
    CGFloat completeTextHeight = textHeight;
    _textView.scrollEnabled = textHeight > _maxHeight;
    textHeight = MIN(_maxHeight, textHeight);
    
    if (ABS(_currentHeight - textHeight) > FLT_EPSILON) {
        _currentHeight = textHeight;
        CGRect frame = self.frame;
        frame.size.height = MAX(40.0f, _currentHeight);
        self.frame = frame;
        
        if (_heightChanged) {
            _heightChanged(textHeight);
        }
    }
    
    _backgroundView.frame = self.bounds;
    
    _placeholderView.frame = CGRectMake(10.0f, CGFloor((40.0f - _placeholderView.frame.size.height) / 2.0f), _placeholderView.frame.size.width, _placeholderView.frame.size.height);
    
    CGRect textViewFrame = self.bounds;
    _textView.frame = textViewFrame;
    
    _textView.contentOffset = CGPointMake(0.0f, completeTextHeight - _textView.bounds.size.height);
    
    /*if (_textView.scrollEnabled) {
        _textView.contentOffset = CGPointZero;
    } else {
        _textView.contentOffset = CGPointMake(0.0f, completeTextHeight - _placeholderView.bounds.size.height);
    }*/
}

- (void)textViewDidChange:(UITextView *)__unused textView {
    _placeholderView.hidden = _textView.text.length != 0;
    
    [self setNeedsLayout];
}

- (UIEdgeInsets)insets {
    return UIEdgeInsetsMake(11.0f, 5.0f, 11.0f, 5.0f);
}

- (CGFloat)heightForText:(NSString *)text width:(CGFloat)width {
    UIEdgeInsets insets = [self insets];
    return CGCeil([text.length == 0 ? @" " : text sizeWithFont:_textView.font constrainedToSize:CGSizeMake(width - insets.left - insets.right - 10.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + insets.top + insets.bottom);
}

- (NSString *)text {
    return _textView.text;
}

@end
