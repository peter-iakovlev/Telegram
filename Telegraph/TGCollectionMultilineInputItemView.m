#import "TGCollectionMultilineInputItemView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGCollectionMultilineInputItemView () <UITextViewDelegate> {
    UILabel *_placeholderLabel;
    UITextView *_textView;
}

@end

@implementation TGCollectionMultilineInputItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor blackColor];
        _textView.font = [TGCollectionMultilineInputItemView font];
        _textView.delegate = self;
        _textView.scrollEnabled = false;
        if (iosMajorVersion() >= 7) {
            _textView.contentInset = UIEdgeInsetsZero;
            _textView.textContainerInset = [TGCollectionMultilineInputItemView insets];
        } else {
            _textView.contentInset = [TGCollectionMultilineInputItemView insets];
        }
        [self.contentView addSubview:_textView];
        
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.font = _textView.font;
        _placeholderLabel.textColor = UIColorRGB(0xc7c7cd);
        [self.contentView addSubview:_placeholderLabel];
    }
    return self;
}

+ (UIFont *)font {
    return TGSystemFontOfSize(16.0f);
}

+ (UIEdgeInsets)insets {
    return UIEdgeInsetsMake(13.0f, 11.0f, 13.0f, 11.0f);
}

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width {
    UIEdgeInsets insets = [self insets];
    return CGCeil([text.length == 0 ? @" " : text sizeWithFont:[self font] constrainedToSize:CGSizeMake(width - insets.left - insets.right - 10.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + insets.top + insets.bottom);
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _placeholderLabel.text = placeholder;
    [_placeholderLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text {
    _text = text;
    _textView.text = text;
    _placeholderLabel.hidden = _text.length != 0;
}

- (void)setEditable:(bool)editable {
    _editable = editable;
    _textView.editable = editable;
    _textView.userInteractionEnabled = editable;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *result = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (_maxLength != 0 && result.length > _maxLength) {
        _textView.text = [result substringToIndex:_maxLength];
        [self textViewDidChange:textView];
        return false;
    }
    return true;
}

- (void)textViewDidChange:(UITextView *)__unused textView {
    _text = _textView.text;
    _placeholderLabel.hidden = _text.length != 0;
    if (_textChanged) {
        _textChanged(_text);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets insets = [TGCollectionMultilineInputItemView insets];
    _placeholderLabel.frame = CGRectOffset(_placeholderLabel.bounds, insets.left + 5.0f, insets.top + TGRetinaPixel);
    _textView.frame = self.bounds;
}

@end
