#import "TGSuggestedLocalizationControllerView.h"

#import "TGAnimationUtils.h"

#import "TGCommentCollectionItem.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGModernButton.h"

#import "TGLocalizationSignals.h"
#import "TGLocalization.h"

@interface TGSuggestedLocalizationControllerView () <UITextFieldDelegate> {
    TGSuggestedLocalization *_suggestedLocalization;
    
    UIView *_dimmingView;
    UIImageView *_backgroundView;
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    TGModernButton *_englishButton;
    UIImageView *_currentCheckView;
    TGModernButton *_suggestedButton;
    UIImageView *_suggestedCheckView;
    TGModernButton *_otherButton;
    UIImageView *_otherDisclosureView;
    
    TGModernButton *_okButton;
    
    UIView *_buttonsHorizontalSeparator;
    UIView *_topSeparator;
    UIView *_middleSeparator;
    UIView *_bottomSeparator;
    
    SMetaDisposable *_disposable;
    
    bool _swapLanguages;
}

@end

@implementation TGSuggestedLocalizationControllerView

- (NSAttributedString *)attributedButtonTitle:(NSString *)top bottom:(NSString *)bottom {
    NSMutableAttributedString *topString = [[NSMutableAttributedString alloc] initWithString:[top stringByAppendingString:@"\n"] attributes:@{NSFontAttributeName: TGSystemFontOfSize(17.0f), NSForegroundColorAttributeName: [UIColor blackColor]}];
    NSAttributedString *bottomString = [[NSAttributedString alloc] initWithString:bottom attributes:@{NSFontAttributeName: TGSystemFontOfSize(12.0f), NSForegroundColorAttributeName: UIColorRGB(0x89898e)}];
    [topString appendAttributedString:bottomString];
    return topString;
}

- (instancetype)initWithSuggestedLocalization:(TGSuggestedLocalization *)suggestedLocalization {
    self = [super initWithFrame:CGRectZero];
    if (self != nil) {
        _suggestedLocalization = suggestedLocalization;
        
        _disposable = [[SMetaDisposable alloc] init];
        
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
        
        TGLocalization *englishLocalization = nativeEnglishLocalization();
        
        _backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        _backgroundView.userInteractionEnabled = true;
        [self addSubview:_backgroundView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = nil;
        _titleLabel.opaque = false;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGBoldSystemFontOfSize(17.0f);
        _titleLabel.text = _suggestedLocalization.chooseLanguageString;
        [_titleLabel sizeToFit];
        [_backgroundView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.backgroundColor = nil;
        _subtitleLabel.opaque = false;
        _subtitleLabel.textColor = UIColorRGB(0x89898e);
        _subtitleLabel.font = TGSystemFontOfSize(12.0f);
        _subtitleLabel.text = [englishLocalization get:@"Localization.ChooseLanguage"];
        [_subtitleLabel sizeToFit];
        [_backgroundView addSubview:_subtitleLabel];
        
        _buttonsHorizontalSeparator = [[UIView alloc] init];
        _buttonsHorizontalSeparator.userInteractionEnabled = false;
        _buttonsHorizontalSeparator.backgroundColor = UIColorRGB(0xf2f2f3);
        [_backgroundView addSubview:_buttonsHorizontalSeparator];
        
        _topSeparator = [[UIView alloc] init];
        _topSeparator.userInteractionEnabled = false;
        _topSeparator.backgroundColor = UIColorRGB(0xf2f2f3);
        [_backgroundView addSubview:_topSeparator];
        
        _middleSeparator = [[UIView alloc] init];
        _middleSeparator.userInteractionEnabled = false;
        _middleSeparator.backgroundColor = UIColorRGB(0xf2f2f3);
        [_backgroundView addSubview:_middleSeparator];
        
        _bottomSeparator = [[UIView alloc] init];
        _bottomSeparator.userInteractionEnabled = false;
        _bottomSeparator.backgroundColor = UIColorRGB(0xf2f2f3);
        [_backgroundView addSubview:_bottomSeparator];
        
        _okButton = [[TGModernButton alloc] init];
        _okButton.titleLabel.font = TGSystemFontOfSize(17.0f);
        [_okButton setTitleColor:TGAccentColor()];
        [_backgroundView addSubview:_okButton];
        [_okButton setTitle:TGLocalized(@"Common.OK") forState:UIControlStateNormal];
        [_okButton addTarget:self action:@selector(okPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _englishButton = [[TGModernButton alloc] init];
        _englishButton.highlightBackgroundColor = TGSelectionColor();
        _englishButton.titleLabel.font = TGSystemFontOfSize(17.0f);
        [_backgroundView addSubview:_englishButton];
        
        [_englishButton setAttributedTitle:[self attributedButtonTitle:_suggestedLocalization.englishLanguageNameString bottom:@"English"] forState:UIControlStateNormal];
        
        _englishButton.titleLabel.numberOfLines = 2;
        _englishButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _englishButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
        _englishButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_englishButton addTarget:self action:@selector(englishPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_englishButton];
        
        _currentCheckView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernMenuCheck.png"]];
        [_englishButton addSubview:_currentCheckView];
        
        _suggestedButton = [[TGModernButton alloc] init];
        _suggestedButton.highlightBackgroundColor = TGSelectionColor();
        _suggestedButton.titleLabel.font = TGSystemFontOfSize(17.0f);
        [_backgroundView addSubview:_suggestedButton];
        [_suggestedButton setAttributedTitle:[self attributedButtonTitle:_suggestedLocalization.info.localizedTitle bottom:_suggestedLocalization.info.title] forState:UIControlStateNormal];
        _suggestedButton.titleLabel.numberOfLines = 2;
        _suggestedButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _suggestedButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
        _suggestedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_suggestedButton addTarget:self action:@selector(suggestedPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_suggestedButton];
        
        _suggestedCheckView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernMenuCheck.png"]];
        _suggestedCheckView.hidden = true;
        [_suggestedButton addSubview:_suggestedCheckView];
        
        NSArray *automaticLanguages = @[@"ko", @"it", @"pt", @"nl", @"de", @"es", @"ar"];
        if (currentCustomLocalization().isActive || [automaticLanguages containsObject:_suggestedLocalization.info.code]) {
            _currentCheckView.hidden = true;
            _suggestedCheckView.hidden = false;
            _swapLanguages = true;
        }
        
        _otherButton = [[TGModernButton alloc] init];
        _otherButton.highlightBackgroundColor = TGSelectionColor();
        _otherButton.titleLabel.font = TGSystemFontOfSize(17.0f);
        [_otherButton setTitleColor:[UIColor blackColor]];
        [_backgroundView addSubview:_otherButton];
        if (!TGStringCompare([englishLocalization get:@"Localization.LanguageOther"], _suggestedLocalization.chooseLanguageOtherString)) {
            [_otherButton setAttributedTitle:[self attributedButtonTitle:_suggestedLocalization.chooseLanguageOtherString bottom:[englishLocalization get:@"Localization.LanguageOther"]] forState:UIControlStateNormal];
            _otherButton.titleLabel.numberOfLines = 2;
            _otherButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        } else {
            [_otherButton setTitle:_suggestedLocalization.chooseLanguageOtherString forState:UIControlStateNormal];
        }
        _otherButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
        _otherButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_otherButton addTarget:self action:@selector(otherPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_otherButton];
        
        _otherDisclosureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernListsDisclosureIndicator.png"]];
        [_otherButton addSubview:_otherDisclosureView];
        
        //[_dimmingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimViewTapGesture:)]];
    }
    return self;
}

- (void)dealloc {
    [_disposable dispose];
}

- (void)animateIn {
    [_dimmingView.layer animateAlphaFrom:0.0f to:1.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
    
    [_backgroundView.layer animateAlphaFrom:0.0f to:1.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
    [_backgroundView.layer animateScaleFrom:1.2f to:1.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:true completion:nil];
}

- (void)animateOut:(void (^)())completion {
    [_dimmingView.layer animateAlphaFrom:1.0f to:0.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:false completion:nil];
    
    [_backgroundView.layer animateAlphaFrom:1.0f to:0.0f duration:0.3 timingFunction:kCAMediaTimingFunctionEaseInEaseOut removeOnCompletion:false completion:^(__unused bool flag) {
        if (completion) {
            completion();
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    _dimmingView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(19.0f, 18.0f, 14.0f, 18.0f);
    CGFloat buttonsHeight = 44.0f;
    CGFloat languageButtonsHeight = 58.0f;
    
    CGFloat maxBackgroundWidth = MIN(270.0f, size.width - 80.0f);
    
    CGSize titleSize = _titleLabel.bounds.size;
    CGSize subtitleSize = _subtitleLabel.bounds.size;
    
    CGRect contentRect = CGRectMake(0.0f, 20.0f, size.width, size.height - 20.0f - _insets.bottom);
    
    CGFloat backgroundWidth = MAX(subtitleSize.width, titleSize.width) + contentInsets.left + contentInsets.right;
    backgroundWidth = maxBackgroundWidth;
    CGFloat backgroundHeight = 279.0f;
    
    CGRect backgroundFrame = CGRectMake(CGFloor((size.width - backgroundWidth) / 2.0f), contentRect.origin.y + CGFloor((contentRect.size.height - backgroundHeight) / 2.0f), backgroundWidth, backgroundHeight);
    _backgroundView.frame = backgroundFrame;
    
    _titleLabel.frame = CGRectMake(CGFloor((backgroundFrame.size.width - titleSize.width) / 2.0f), contentInsets.top, titleSize.width, titleSize.height);
    _subtitleLabel.frame = CGRectMake(CGFloor((backgroundFrame.size.width - subtitleSize.width) / 2.0f), contentInsets.top + titleSize.height + 1.0f, subtitleSize.width, subtitleSize.height);
    
    CGFloat buttonsOffset = 74.0f;
    CGRect bottomButtonFrame = CGRectMake(0.0f, buttonsOffset + languageButtonsHeight, backgroundFrame.size.width, languageButtonsHeight);
    CGRect topButtonFrame = CGRectMake(0.0f, buttonsOffset, backgroundFrame.size.width, languageButtonsHeight);
    
    if (_swapLanguages) {
        _englishButton.frame = bottomButtonFrame;
        _suggestedButton.frame = topButtonFrame;
    } else {
        _englishButton.frame = topButtonFrame;
        _suggestedButton.frame = bottomButtonFrame;
    }
    _topSeparator.frame = CGRectMake(0.0f, buttonsOffset, backgroundWidth, TGScreenPixel);
    _middleSeparator.frame = CGRectMake(0.0f, buttonsOffset + languageButtonsHeight, backgroundWidth, TGScreenPixel);
    _otherButton.frame = CGRectMake(0.0f, buttonsOffset + languageButtonsHeight * 2.0f, backgroundFrame.size.width, buttonsHeight);
    _bottomSeparator.frame = CGRectMake(0.0f, buttonsOffset + languageButtonsHeight * 2.0f, backgroundWidth, TGScreenPixel);
    
    _suggestedCheckView.frame = CGRectMake(backgroundFrame.size.width - 33.0f, 22.0f, _suggestedCheckView.frame.size.width, _suggestedCheckView.frame.size.height);
    _currentCheckView.frame = CGRectMake(backgroundFrame.size.width - 33.0f, 22.0f, _currentCheckView.frame.size.width, _currentCheckView.frame.size.height);
    _otherDisclosureView.frame = CGRectMake(backgroundFrame.size.width - 24.0f, 15.0f, _otherDisclosureView.frame.size.width, _otherDisclosureView.frame.size.height);
    
    _buttonsHorizontalSeparator.frame = CGRectMake(0.0f, backgroundHeight - buttonsHeight, backgroundWidth, TGScreenPixel);
    
    _okButton.frame = CGRectMake(0.0f, backgroundHeight - buttonsHeight, backgroundWidth, buttonsHeight);
}

- (void)dimViewTapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_dismiss) {
            _dismiss();
        }
    }
}

- (void)okPressed {
    if (!_okButton.enabled) {
        return;
    }
    
    if (!_suggestedCheckView.hidden) {
        _okButton.enabled = false;
        [_okButton setTitleColor:[UIColor grayColor]];
        
        __weak TGSuggestedLocalizationControllerView *weakSelf = self;
        
        [_disposable setDisposable:[[[TGLocalizationSignals applyLocalization:_suggestedLocalization.info.code] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error) {
            __strong TGSuggestedLocalizationControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_okButton.enabled = true;
                [strongSelf->_okButton setTitleColor:TGAccentColor()];
            }
        } completed:^{
            __strong TGSuggestedLocalizationControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_appliedLanguage) {
                    strongSelf->_appliedLanguage();
                }
                if (strongSelf->_dismiss) {
                    strongSelf->_dismiss();
                }
            }
        }]];
    } else {
        if (![effectiveLocalization().code isEqualToString:@"en"]) {
            _okButton.enabled = false;
            [_okButton setTitleColor:[UIColor grayColor]];
            
            __weak TGSuggestedLocalizationControllerView *weakSelf = self;
            
            [_disposable setDisposable:[[[TGLocalizationSignals applyLocalization:@"en"] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error) {
                __strong TGSuggestedLocalizationControllerView *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_okButton.enabled = true;
                    [strongSelf->_okButton setTitleColor:TGAccentColor()];
                }
            } completed:^{
                __strong TGSuggestedLocalizationControllerView *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (strongSelf->_appliedLanguage) {
                        strongSelf->_appliedLanguage();
                    }
                    if (strongSelf->_dismiss) {
                        strongSelf->_dismiss();
                    }
                }
            }]];
        } else {
            if (_appliedLanguage) {
                _appliedLanguage();
            }
            if (_dismiss) {
                _dismiss();
            }
        }
    }
}

- (void)englishPressed {
    _currentCheckView.hidden = false;
    _suggestedCheckView.hidden = true;
}

- (void)suggestedPressed {
    _currentCheckView.hidden = true;
    _suggestedCheckView.hidden = false;
}

- (void)otherPressed {
    if (_dismiss) {
        _dismiss();
    }
    if (_other) {
        _other();
    }
}

@end
