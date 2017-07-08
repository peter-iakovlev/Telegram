#import "TGPaymentPasswordEntryControllerView.h"

#import "TGAnimationUtils.h"

#import "TGCommentCollectionItem.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGModernButton.h"

@interface TGPaymentPasswordEntryControllerView () <UITextFieldDelegate> {
    UIView *_dimmingView;
    UIImageView *_backgroundView;
    
    UILabel *_titleLabel;
    UILabel *_textLabel;
    NSAttributedString *_attributedText;
    
    UIImageView *_textFieldBackground;
    UITextField *_textField;
    
    UIView *_buttonsHorizontalSeparator;
    UIView *_buttonsVerticalSeparator;
    
    TGModernButton *_leftButton;
    TGModernButton *_rightButton;
    
    SMetaDisposable *_disposable;
    SVariable *_fieldTextEmpty;
    SVariable *_inProgress;
    
    id<SDisposable> _enableButtonDisposable;
    id<SDisposable> _enableTextFieldDisposable;
    bool _enableTextField;
}

@end

@implementation TGPaymentPasswordEntryControllerView

- (instancetype)initWithCardTitle:(NSString *)cardTitle {
    self = [super initWithFrame:CGRectZero];
    if (self != nil) {
        _disposable = [[SMetaDisposable alloc] init];
        _fieldTextEmpty = [[SVariable alloc] init];
        [_fieldTextEmpty set:[SSignal single:@true]];
        _inProgress = [[SVariable alloc] init];
        [_inProgress set:[SSignal single:@false]];
        
        _dimmingView = [[UIView alloc] init];
        _dimmingView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        [self addSubview:_dimmingView];
        
        static UIImage *backgroundImage = nil;
        static UIImage *textFieldBackgroundImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            {
                CGFloat diameter = 26.0f;
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
                UIGraphicsEndImageContext();
            }
            {
                CGFloat diameter = 4.0f;
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetFillColorWithColor(context, UIColorRGB(0x98979e).CGColor);
                CGContextFillRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                CGContextFillRect(context, CGRectMake(TGScreenPixel, TGScreenPixel, diameter - TGScreenPixel * 2.0, diameter - TGScreenPixel * 2.0f));
                
                textFieldBackgroundImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0f) topCapHeight:(NSInteger)(diameter / 2.0f)];
                UIGraphicsEndImageContext();
            }
        });
        _backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        _backgroundView.userInteractionEnabled = true;
        [self addSubview:_backgroundView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = nil;
        _titleLabel.opaque = false;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGBoldSystemFontOfSize(17.0f);
        _titleLabel.text = TGLocalized(@"Checkout.PasswordEntry.Title");
        [_titleLabel sizeToFit];
        [_backgroundView addSubview:_titleLabel];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = nil;
        _textLabel.opaque = false;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_backgroundView addSubview:_textLabel];
        
        _attributedText = [TGCommentCollectionItem attributedStringFromText:[NSString stringWithFormat:TGLocalized(@"Checkout.PasswordEntry.Text"), [NSString stringWithFormat:@"**%@**", cardTitle]] allowFormatting:true paragraphSpacing:1.0f alignment:NSTextAlignmentCenter fontSize:13.0f clearFormatting:false];
        _textLabel.attributedText = _attributedText;
        
        _textFieldBackground = [[UIImageView alloc] initWithImage:textFieldBackgroundImage];
        _textFieldBackground.userInteractionEnabled = true;
        [_backgroundView addSubview:_textFieldBackground];
        
        _textField = [[UITextField alloc] init];
        _textField.textColor = [UIColor blackColor];
        _textField.font = TGSystemFontOfSize(12.0f);
        _textField.typingAttributes = @{NSFontAttributeName: TGSystemFontOfSize(12.0f)};
        _textField.secureTextEntry = true;
        [_textField addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
        _textField.delegate = self;
        [_backgroundView addSubview:_textField];
        
        _buttonsHorizontalSeparator = [[UIView alloc] init];
        _buttonsHorizontalSeparator.userInteractionEnabled = false;
        _buttonsHorizontalSeparator.backgroundColor = UIColorRGB(0x98979e);
        [_backgroundView addSubview:_buttonsHorizontalSeparator];
        
        _buttonsVerticalSeparator = [[UIView alloc] init];
        _buttonsVerticalSeparator.userInteractionEnabled = false;
        _buttonsVerticalSeparator.backgroundColor = UIColorRGB(0x98979e);
        [_backgroundView addSubview:_buttonsVerticalSeparator];
        
        _leftButton = [[TGModernButton alloc] init];
        _leftButton.titleLabel.font = TGSystemFontOfSize(17.0f);
        [_leftButton setTitleColor:TGAccentColor()];
        [_backgroundView addSubview:_leftButton];
        [_leftButton setTitle:TGLocalized(@"Common.Cancel") forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _rightButton = [[TGModernButton alloc] init];
        _rightButton.titleLabel.font = TGBoldSystemFontOfSize(17.0f);
        [_rightButton setTitleColor:TGAccentColor()];
        //_rightButton.modernHighlight = true;
        [_backgroundView addSubview:_rightButton];
        [_rightButton setTitle:TGLocalized(@"Checkout.PasswordEntry.Pay") forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(payPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [_dimmingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimViewTapGesture:)]];
        
        __weak TGPaymentPasswordEntryControllerView *weakSelf = self;
        _enableButtonDisposable = [[[SSignal combineSignals:@[_fieldTextEmpty.signal, _inProgress.signal]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray<NSNumber *> *values) {
            __strong TGPaymentPasswordEntryControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                bool enabled = ![values[0] boolValue] && ![values[1] boolValue];

                strongSelf->_rightButton.enabled = enabled;
                [strongSelf->_rightButton setTitleColor:enabled ? TGAccentColor() : [UIColor grayColor]];
            }
        }];
        _enableTextFieldDisposable = [[_inProgress.signal deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *value) {
            __strong TGPaymentPasswordEntryControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                bool enabled = ![value boolValue];
                strongSelf->_enableTextField = enabled;
                strongSelf->_textField.alpha = enabled ? 1.0f : 0.5f;
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [_disposable dispose];
    [_enableButtonDisposable dispose];
    [_enableTextFieldDisposable dispose];
}

- (void)animateIn {
    [_dimmingView.layer animateAlphaFrom:0.0f to:1.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
    
    [_backgroundView.layer animateAlphaFrom:0.0f to:1.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
    [_backgroundView.layer animateScaleFrom:0.8f to:1.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
    
    [_textField becomeFirstResponder];
}

- (void)animateOut:(void (^)())completion {
    [_dimmingView.layer animateAlphaFrom:1.0f to:0.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:false completion:nil];
    
    [_backgroundView.layer animateAlphaFrom:1.0f to:0.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:false completion:^(__unused bool flag) {
        if (completion) {
            completion();
        }
    }];
    /*[_backgroundView.layer animateScaleFrom:1.0f to:8.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:false completion:^(__unused bool flag) {
        if (completion) {
            completion();
        }
    }];*/
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    _dimmingView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(18.0f, 18.0f, 14.0f, 18.0f);
    CGFloat titleTextSpacing = 6.0f;
    CGFloat textFieldHeight = 25.0f;
    CGFloat textFieldSpacing = 14.0f;
    CGFloat buttonsHeight = 44.0f;
    
    CGFloat maxBackgroundWidth = MIN(270.0f, size.width - 40.0f);
    
    CGSize titleSize = _titleLabel.bounds.size;
    CGSize textSize = [_attributedText boundingRectWithSize:CGSizeMake(maxBackgroundWidth - contentInsets.left - contentInsets.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGRect contentRect = CGRectMake(0.0f, 20.0f, size.width, size.height - 20.0f - _insets.bottom);
    
    CGFloat backgroundWidth = MAX(textSize.width, titleSize.width) + contentInsets.left + contentInsets.right;
    CGFloat backgroundHeight = titleSize.height + titleTextSpacing + textSize.height + textFieldSpacing + textFieldHeight + contentInsets.top + contentInsets.bottom + buttonsHeight;
    
    CGRect backgroundFrame = CGRectMake(CGFloor((size.width - backgroundWidth) / 2.0f), contentRect.origin.y + CGFloor((contentRect.size.height - backgroundHeight) / 2.0f), backgroundWidth, backgroundHeight);
    _backgroundView.frame = backgroundFrame;
    
    _titleLabel.frame = CGRectMake(CGFloor((backgroundFrame.size.width - titleSize.width) / 2.0f), contentInsets.top, titleSize.width, titleSize.height);
    CGRect textLabelFrame = CGRectMake(CGFloor((backgroundFrame.size.width - textSize.width) / 2.0f), contentInsets.top + titleSize.height + titleTextSpacing, textSize.width, textSize.height);
    _textLabel.frame = textLabelFrame;
    
    CGRect textFieldFrame = CGRectMake(contentInsets.left + 1.0f, CGRectGetMaxY(textLabelFrame) + textFieldSpacing, backgroundWidth - contentInsets.left - contentInsets.right - 2.0f, textFieldHeight);
    _textFieldBackground.frame = textFieldFrame;
    _textField.frame = CGRectInset(textFieldFrame, 3.0f, 3.0f);
    
    _buttonsHorizontalSeparator.frame = CGRectMake(0.0f, backgroundHeight - buttonsHeight, backgroundWidth, TGScreenPixel);
    _buttonsVerticalSeparator.frame = CGRectMake(CGFloor(backgroundWidth / 2.0f), backgroundHeight - buttonsHeight, TGScreenPixel, buttonsHeight);
    _leftButton.frame = CGRectMake(0.0f, backgroundHeight - buttonsHeight, CGFloor(backgroundWidth / 2.0f), buttonsHeight);
    _rightButton.frame = CGRectMake(CGFloor(backgroundWidth / 2.0f), backgroundHeight - buttonsHeight, backgroundWidth - CGFloor(backgroundWidth / 2.0f), buttonsHeight);
}

- (void)dimViewTapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_dismiss) {
            _dismiss();
        }
    }
}

- (BOOL)textField:(UITextField *)__unused textField shouldChangeCharactersInRange:(NSRange)__unused range replacementString:(NSString *)__unused string {
    return _enableTextField;
}

- (void)textFieldTextChanged:(UITextField *)textField {
    [_fieldTextEmpty set:[SSignal single:@(textField.text.length == 0)]];
}

- (void)cancelPressed {
    if (_dismiss) {
        _dismiss();
    }
}

- (void)shakeView:(UIView *)v originalX:(CGFloat)originalX
{
    CGRect r = v.frame;
    r.origin.x = originalX;
    CGRect originalFrame = r;
    CGRect rFirst = r;
    rFirst.origin.x = r.origin.x + 4;
    r.origin.x = r.origin.x - 4;
    
    v.frame = v.frame;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionAutoreverse animations:^
     {
         v.frame = rFirst;
     } completion:^(BOOL finished)
     {
         if (finished)
         {
             [UIView animateWithDuration:0.05 delay:0.0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse) animations:^
              {
                  [UIView setAnimationRepeatCount:3];
                  v.frame = r;
              } completion:^(__unused BOOL finished)
              {
                  v.frame = originalFrame;
              }];
         }
         else
             v.frame = originalFrame;
     }];
}

- (void)payPressed {
    if (_payWithPassword) {
        [_inProgress set:[SSignal single:@true]];
        
        __weak TGPaymentPasswordEntryControllerView *weakSelf = self;
        SSignal *signal = [[_payWithPassword(_textField.text) deliverOn:[SQueue mainQueue]] onDispose:^{
            __strong TGPaymentPasswordEntryControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_inProgress set:[SSignal single:@false]];
            }
        }];
        [_disposable setDisposable:[signal startWithNext:nil error:^(__unused id error) {
            __strong TGPaymentPasswordEntryControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf shakeView:strongSelf->_textField originalX:strongSelf->_textField.frame.origin.x];
                [strongSelf shakeView:strongSelf->_textFieldBackground originalX:strongSelf->_textFieldBackground.frame.origin.x];
            }
        } completed:^{
            __strong TGPaymentPasswordEntryControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf cancelPressed];
            }
        }]];
    }
}

@end
