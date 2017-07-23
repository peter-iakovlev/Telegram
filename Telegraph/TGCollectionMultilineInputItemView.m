#import "TGCollectionMultilineInputItemView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGCollectionMultilineInputItemView () <UITextViewDelegate> {
    UILabel *_placeholderLabel;
    UITextView *_textView;
    UILabel *_countLabel;
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
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = _textView.font;
        _countLabel.textColor = UIColorRGB(0xc7c7cd);
        _countLabel.userInteractionEnabled = false;
        _countLabel.hidden = true;
        _countLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_countLabel];
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
    [self updateRemainingCount];
}

- (void)setMaxLength:(NSUInteger)maxLength {
    _maxLength = maxLength;
    [self updateRemainingCount];
}

- (void)setEditable:(bool)editable {
    _editable = editable;
    _textView.editable = editable;
    _textView.userInteractionEnabled = editable;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    _textView.returnKeyType = returnKeyType;
}

- (void)setShowRemainingCount:(bool)showRemainingCount
{
    _showRemainingCount = showRemainingCount;
    _countLabel.hidden = !showRemainingCount;
}

- (void)updateRemainingCount {
    _countLabel.text = [NSString stringWithFormat:@"%ld", _maxLength - _text.length];
    [_countLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    [self setNeedsLayout];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (_disallowNewLines && [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound)
    {
        if ([text isEqualToString:@"\n"])
        {
            [textView resignFirstResponder];
            if (self.returned)
                self.returned();
        }
        else
        {
            NSString *newReplacementText = [[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
            NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:newReplacementText];
            NSUInteger length = newText.length;
            if (length > _maxLength)
            {
                NSUInteger difference = length - _maxLength;
                newText = [textView.text stringByReplacingCharactersInRange:range withString:[newReplacementText substringToIndex:length - difference]];
            }
            
            _textView.text = newText;
            [self textViewDidChange:textView];
        }
        return false;
    }

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
    [self updateRemainingCount];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets insets = [TGCollectionMultilineInputItemView insets];
    UIEdgeInsets additionalInsets = self.insets;
    _placeholderLabel.frame = CGRectOffset(_placeholderLabel.bounds, insets.left + additionalInsets.left + 5.0f, insets.top + additionalInsets.top + TGRetinaPixel);
    CGRect frame = self.bounds;
    if (!_countLabel.hidden)
        frame.size.width -= 30.0f;
    frame.size.width -= additionalInsets.left + additionalInsets.right;
    frame.origin.x += additionalInsets.left;
    
    _textView.frame = frame;
    _countLabel.frame = CGRectMake(self.bounds.size.width - insets.right - 30.0f - 4.0f, insets.top + TGRetinaPixel, 30.0f, _countLabel.frame.size.height);
}

- (BOOL)becomeFirstResponder {
    return [_textView becomeFirstResponder];
}

@end
