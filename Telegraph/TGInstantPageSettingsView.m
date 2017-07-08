#import "TGInstantPageSettingsView.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGInstantPageLayout.h"

#import "TGModernButton.h"
#import "TGPhotoEditorSliderView.h"
#import "TGInstantPageColorView.h"

@interface TGInstantPageSettingsView ()
{
    CGPoint _settingsButtonPosition;
    
    UIButton *_fadeView;
    UIImageView *_arrowView;
    UIScrollView *_scrollView;
    UIView *_panelWrapperView;
    UIView *_panelView;
    
    UIImageView *_brightnessMinIconView;
    UIImageView *_brightnessMaxIconView;
    TGPhotoEditorSliderView *_brightnessSliderView;
    
    UIImageView *_fontMinIconView;
    UIImageView *_fontMaxIconView;
    TGPhotoEditorSliderView *_fontSliderView;
    
    NSArray *_colorViews;
    TGInstantPageColorView *_whiteColorView;
    TGInstantPageColorView *_brownColorView;
    TGInstantPageColorView *_grayColorView;
    TGInstantPageColorView *_blackColorView;
    
    UILabel *_autoThemeLabel;
    UIView *_autoThemeWrapperView;
    UISwitch *_autoThemeSwitch;
    bool _autoNight;
    
    TGModernButton *_sansSerifFontButton;
    TGModernButton *_serifFontButton;
    UIImageView *_checkView;
    bool _fontSerif;
    
    UIImage *_separatorImage;
    UIImageView *_firstSepartorView;
    UIImageView *_secondSepartorView;
    
    UIImageView *_fontSeparatorLineView;
    UIImageView *_fontShortSeparatorLineView;
    UIImageView *_themeSeparatorLineView;
    UIImage *_separatorLineImage;
    UIImage *_separatorLineDarkImage;
}
@end

@implementation TGInstantPageSettingsView

- (instancetype)initWithFrame:(CGRect)frame presentation:(TGInstantPagePresentation *)presentation autoNightThemeEnabled:(bool)autoNightThemeEnabled {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _fadeView = [[UIButton alloc] initWithFrame:self.bounds];
        _fadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _fadeView.backgroundColor = UIColorRGBA(0x000000, 0.1f);
        _fadeView.exclusiveTouch = true;
        [_fadeView addTarget:self action:@selector(fadeTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_fadeView];
        
        _panelWrapperView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 296.0f, 338.0f)];
        [self addSubview:_panelWrapperView];
        
        _panelView = [[UIView alloc] initWithFrame:_panelWrapperView.bounds];
        _panelView.clipsToBounds = true;
        _panelView.layer.cornerRadius = 13.0f;
        [_panelWrapperView addSubview:_panelView];
        
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InstantViewSettingsArrow"]];
        [_panelWrapperView addSubview:_arrowView];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 296.0f, 338.0f)];
        _scrollView.contentSize = CGSizeMake(296.0f, 338.0f);
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.showsHorizontalScrollIndicator = false;
        [_panelView addSubview:_scrollView];
        
        _brightnessMinIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InstantViewBrightnessMinIcon"]];
        [_scrollView addSubview:_brightnessMinIconView];
        
        _brightnessMaxIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InstantViewBrightnessMaxIcon"]];
        [_scrollView addSubview:_brightnessMaxIconView];
        
        static UIImage *knobViewImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0f, 40.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetShadowWithColor(context, CGSizeMake(0, 1.5f), 3.5f, [UIColor colorWithWhite:0.0f alpha:0.25f].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(6.0f, 6.0f, 28.0f, 28.0f));
            knobViewImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _brightnessSliderView = [[TGPhotoEditorSliderView alloc] initWithFrame:CGRectMake(38.0f, 8.0f + TGScreenPixel, 216.0f, 44.0f)];
        _brightnessSliderView.backgroundColor = [UIColor whiteColor];
        _brightnessSliderView.knobImage = knobViewImage;
        _brightnessSliderView.trackCornerRadius = 1.0f;
        _brightnessSliderView.trackColor = TGAccentColor();
        _brightnessSliderView.backColor = UIColorRGB(0xb7b7b7);
        _brightnessSliderView.lineSize = 2.0f;
        _brightnessSliderView.minimumValue = 0.0f;
        _brightnessSliderView.startValue = 0.0f;
        _brightnessSliderView.maximumValue = 100.0f;
        _brightnessSliderView.value = [UIScreen mainScreen].brightness * 100.0f;
        [_brightnessSliderView addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
        
        __weak TGInstantPageSettingsView *weakSelf = self;
        _brightnessSliderView.interactionBegan = ^{
            __strong TGInstantPageSettingsView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setFadeHidden:true animated:true];
            }
        };
        _brightnessSliderView.interactionEnded = ^{
            __strong TGInstantPageSettingsView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setFadeHidden:false animated:true];
            }
        };
        [_scrollView addSubview:_brightnessSliderView];
        
        UIColor *separatorColor = UIColorRGB(0xc8c7cb);
        static dispatch_once_t onceToken2;
        static UIImage *separatorImage;
        static UIImage *separatorLineImage;
        static UIImage *separatorLineDarkImage;
        dispatch_once(&onceToken2, ^{
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(5.0f, 5.0f), false, 0.0f);
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xefeff4).CGColor);
            
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 5.0f, 5.0f));
            
            CGContextSetFillColorWithColor(context, separatorColor.CGColor);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 5.0f, TGScreenPixel));
            CGContextFillRect(context, CGRectMake(0.0f, 5.0f - TGScreenPixel, 5.0f, TGScreenPixel));
        
            separatorImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0f, 1.0f), false, 0.0f);
            
            context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, separatorColor.CGColor);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 1.0f));
            
            separatorLineImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0f, 1.0f), false, 0.0f);
            
            context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0x1b1b1b).CGColor);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 1.0f));
            
            separatorLineDarkImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        _separatorImage = separatorImage;
        _separatorLineImage = separatorLineImage;
        _separatorLineDarkImage = separatorLineDarkImage;
        
        _firstSepartorView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 62.0f, _panelView.frame.size.width, 5.0f)];
        _firstSepartorView.image = separatorImage;
        [_scrollView addSubview:_firstSepartorView];
        
        _fontMinIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InstantViewFontMinIcon"]];
        [_scrollView addSubview:_fontMinIconView];
        
        _fontMaxIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InstantViewFontMaxIcon"]];
        [_scrollView addSubview:_fontMaxIconView];
        
        CGFloat fontValue = 1.0;
        
        if (presentation.fontSizeMultiplier <= 0.85f + FLT_EPSILON)
            fontValue = 0.0f;
        else if (presentation.fontSizeMultiplier <= 1.0f + FLT_EPSILON)
            fontValue = 1.0f;
        else if (presentation.fontSizeMultiplier <= 1.15f + FLT_EPSILON)
            fontValue = 2.0f;
        else if (presentation.fontSizeMultiplier <= 1.3f + FLT_EPSILON)
            fontValue = 3.0f;
        else if (presentation.fontSizeMultiplier <= 1.5f + FLT_EPSILON)
            fontValue = 4.0f;
        
        _fontSliderView = [[TGPhotoEditorSliderView alloc] initWithFrame:CGRectMake(38.0f, 76.0f, 216.0f, 44.0f)];
        _fontSliderView.backgroundColor = [UIColor whiteColor];
        _fontSliderView.knobImage = knobViewImage;
        _fontSliderView.trackCornerRadius = 1.0f;
        _fontSliderView.trackColor = TGAccentColor();
        _fontSliderView.backColor = UIColorRGB(0xb7b7b7);
        _fontSliderView.lineSize = 2.0f;
        _fontSliderView.dotSize = 5.0f;
        _fontSliderView.minimumValue = 0.0f;
        _fontSliderView.maximumValue = 4.0f;
        _fontSliderView.startValue = 0.0f;
        _fontSliderView.value = fontValue;
        _fontSliderView.positionsCount = 5;
        [_fontSliderView addTarget:self action:@selector(fontSizeChanged:) forControlEvents:UIControlEventValueChanged];
        [_scrollView addSubview:_fontSliderView];
        
        _fontSeparatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_firstSepartorView.frame) + 62.0f, _panelView.frame.size.width, TGScreenPixel)];
        _fontSeparatorLineView.image = separatorLineImage;
        [_scrollView addSubview:_fontSeparatorLineView];
        
        _fontShortSeparatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake(46.0f, CGRectGetMaxY(_fontSeparatorLineView.frame) + 44.0f, _panelView.frame.size.width - 46.0f, TGScreenPixel)];
        _fontShortSeparatorLineView.image = separatorLineImage;
        [_scrollView addSubview:_fontShortSeparatorLineView];
        
        _secondSepartorView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_firstSepartorView.frame) + 62.0f + 89.0f, _panelView.frame.size.width, 5.0f)];
        _secondSepartorView.image = separatorImage;
        [_scrollView addSubview:_secondSepartorView];
        
        NSString *sansSerifFontName = iosMajorVersion() >= 9 ? @"San Francisco" : @"Helvetica";
        
        _sansSerifFontButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(_fontSeparatorLineView.frame), _panelView.frame.size.width, 45.0f)];
        _sansSerifFontButton.exclusiveTouch = true;
        _sansSerifFontButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _sansSerifFontButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 46.0f, 0.0f, 0.0f);
        _sansSerifFontButton.titleLabel.font = TGSystemFontOfSize(17.0f);
        [_sansSerifFontButton setTitleColor:[UIColor blackColor]];
        _sansSerifFontButton.highlightBackgroundColor = UIColorRGB(0xebebeb);
        [_sansSerifFontButton setTitle:sansSerifFontName forState:UIControlStateNormal];
        [_sansSerifFontButton addTarget:self action:@selector(fontButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_sansSerifFontButton];
        
        _serifFontButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(_fontShortSeparatorLineView.frame), _panelView.frame.size.width, 45.0f)];
        _serifFontButton.exclusiveTouch = true;
        _serifFontButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _serifFontButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 46.0f, 0.0f, 0.0f);
        _serifFontButton.titleLabel.font = [UIFont fontWithName:@"Georgia" size:17.0f];
        [_serifFontButton setTitleColor:[UIColor blackColor]];
        _serifFontButton.highlightBackgroundColor = UIColorRGB(0xebebeb);
        [_serifFontButton setTitle:@"Georgia" forState:UIControlStateNormal];
        [_serifFontButton addTarget:self action:@selector(fontButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_serifFontButton];

        _fontSerif = presentation.fontSerif;
        _checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaintCheck"]];
        [_scrollView addSubview:_checkView];
        
        _whiteColorView = [[TGInstantPageColorView alloc] initWithFrame:CGRectMake(26.0f, 146.0f + 89.0f, 46.0f, 46.0f)];
        _whiteColorView.color = [UIColor whiteColor];
        _whiteColorView.selected = presentation.initialTheme == TGInstantPagePresentationThemeDefault;
        _whiteColorView.tag = TGInstantPagePresentationThemeDefault;
        [_whiteColorView addTarget:self action:@selector(themeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_whiteColorView];
        
        _brownColorView = [[TGInstantPageColorView alloc] initWithFrame:CGRectMake(92.0f, 146.0f + 89.0f, 46.0f, 46.0f)];
        _brownColorView.color = UIColorRGB(0xd5c59f);
        _brownColorView.selected = presentation.initialTheme == TGInstantPagePresentationThemeBrown;
        _brownColorView.tag = TGInstantPagePresentationThemeBrown;
        [_brownColorView addTarget:self action:@selector(themeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_brownColorView];
        
        _grayColorView = [[TGInstantPageColorView alloc] initWithFrame:CGRectMake(158.0f, 146.0f + 89.0f, 46.0f, 46.0f)];
        _grayColorView.color = UIColorRGB(0x5a5a5c);
        _grayColorView.selected = presentation.initialTheme == TGInstantPagePresentationThemeGray;
        _grayColorView.tag = TGInstantPagePresentationThemeGray;
        [_grayColorView addTarget:self action:@selector(themeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_grayColorView];
        
        _blackColorView = [[TGInstantPageColorView alloc] initWithFrame:CGRectMake(224.0f, 146.0f + 89.0f, 46.0f, 46.0f)];
        _blackColorView.color = UIColorRGB(0x333333);
        _blackColorView.selected = presentation.initialTheme == TGInstantPagePresentationThemeBlack;
        _blackColorView.tag = TGInstantPagePresentationThemeBlack;
        [_blackColorView addTarget:self action:@selector(themeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_blackColorView];
        
        _colorViews = @[_whiteColorView, _brownColorView, _grayColorView, _blackColorView];
        
        _themeSeparatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_secondSepartorView.frame) + 70.0f, _panelView.frame.size.width, TGScreenPixel)];
        _themeSeparatorLineView.image = separatorLineImage;
        [_scrollView addSubview:_themeSeparatorLineView];
        
        _autoThemeLabel = [[UILabel alloc] init];
        _autoThemeLabel.backgroundColor = [UIColor whiteColor];
        _autoThemeLabel.text = TGLocalized(@"InstantPage.AutoNightTheme");
        _autoThemeLabel.font = TGSystemFontOfSize(17.0f);
        _autoThemeLabel.minimumScaleFactor = 0.7f;
        _autoThemeLabel.adjustsFontSizeToFitWidth = true;
        _autoThemeLabel.textColor = [UIColor blackColor];
        [_autoThemeLabel sizeToFit];
        _autoThemeLabel.frame = CGRectMake(14.0f, floor(CGRectGetMaxY(_themeSeparatorLineView.frame)) + 12.0f, MIN(_autoThemeLabel.frame.size.width, 229.0f - 14.0f - 10.0f), _autoThemeLabel.frame.size.height);
        [_scrollView addSubview:_autoThemeLabel];
        
        _autoNight = autoNightThemeEnabled;
        _autoThemeSwitch = [[UISwitch alloc] init];
        _autoThemeSwitch.on = autoNightThemeEnabled && presentation.initialTheme != TGInstantPagePresentationThemeBlack;
        [_autoThemeSwitch addTarget:self action:@selector(autoThemeChanged:) forControlEvents:UIControlEventValueChanged];
        
        _autoThemeWrapperView = [[UIView alloc] initWithFrame:CGRectMake(229.0f, floor(CGRectGetMaxY(_themeSeparatorLineView.frame)) + 7.0f, _autoThemeSwitch.frame.size.width, _autoThemeSwitch.frame.size.height)];
        [_autoThemeWrapperView addSubview:_autoThemeSwitch];
        
        [_scrollView addSubview:_autoThemeWrapperView];
        
        [self updatePresentation:presentation animated:false];
    }
    return self;
}

- (void)setButtonPosition:(CGPoint (^)(void))buttonPosition {
    _settingsButtonPosition = buttonPosition();
}

- (void)brightnessChanged:(TGPhotoEditorSliderView *)sender {
    [UIScreen mainScreen].brightness = sender.value / 100.0f;
}

- (void)fontSizeChanged:(TGPhotoEditorSliderView *)sender {
    if (self.fontSizeChanged != nil) {
        NSInteger intValue = (NSInteger)sender.value;
        CGFloat multiplier = 1.0f;
        switch (intValue) {
            case 0:
                multiplier = 0.85f;
                break;
                
            case 1:
                multiplier = 1.0f;
                break;
            
            case 2:
                multiplier = 1.15f;
                break;
                
            case 3:
                multiplier = 1.30f;
                break;
                
            case 4:
                multiplier = 1.50f;
                break;
                
            default:
                multiplier = 1.0f;
                break;
        }
        
        self.fontSizeChanged(multiplier);
    }
}

- (void)fontButtonPressed:(TGModernButton *)sender {
    _fontSerif = sender == _serifFontButton;
    
    if (self.fontSerifChanged != nil) {
        self.fontSerifChanged(_fontSerif);
    }
    
    [self setNeedsLayout];
}

- (void)themeChanged:(TGInstantPageColorView *)sender {
    for (TGInstantPageColorView *view in _colorViews) {
        view.selected = view == sender;
    }
    
    TGInstantPagePresentationTheme theme = (TGInstantPagePresentationTheme)sender.tag;
    if (self.themeChanged != nil) {
        self.themeChanged(theme);
    }
}

- (void)autoThemeChanged:(UISwitch *)sender {
    _autoNight = sender.isOn;
    
    if (self.autoNightThemeChanged != nil) {
        self.autoNightThemeChanged(sender.isOn);
    }
}

- (void)fadeTapped {
    if (self.dismiss != nil)
        self.dismiss();
}

- (void)transitionIn {
    self.alpha = 0.0f;
    _panelView.layer.rasterizationScale = TGScreenScaling();
    _panelView.layer.shouldRasterize = true;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            _panelView.layer.shouldRasterize = false;
        }
    }];
}

- (void)transitionOut:(void (^)(void))completion {
    _panelView.layer.shouldRasterize = true;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0f;
    } completion:^(__unused BOOL finished) {
        if (completion != nil) {
            completion();
        }
    }];
}

- (void)setFadeHidden:(bool)hidden animated:(bool)animated {
    void (^changeBlock)(void) = ^{
        _fadeView.alpha = hidden ? 0.0f : 1.0f;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:changeBlock];
    } else {
        changeBlock();
    }
}

- (void)updatePresentation:(TGInstantPagePresentation *)presentation animated:(bool)animated {
    UIView *snapshotView = nil;
    
    if (animated) {
        [_autoThemeWrapperView removeFromSuperview];
        snapshotView = [_panelWrapperView snapshotViewAfterScreenUpdates:true];
        snapshotView.frame = CGRectMake(0.0f, _scrollView.contentOffset.y, snapshotView.frame.size.width, snapshotView.frame.size.height);
        [_scrollView addSubview:snapshotView];
        
        [_scrollView addSubview:_autoThemeWrapperView];
    }
    
    UIColor *panelColor = [UIColor whiteColor];
    UIColor *separatorColor = [UIColor clearColor];
    UIColor *textColor = [UIColor blackColor];
    UIColor *selectionColor = UIColorRGB(0xebebeb);
    
    switch (presentation.theme) {
        case TGInstantPagePresentationThemeBrown: {
            UIColor *accentColor = UIColorRGB(0xb06900);
            _brightnessSliderView.trackColor = accentColor;
            _brightnessSliderView.backColor = UIColorRGB(0xb7b7b7);
            _checkView.image = TGTintedImage([UIImage imageNamed:@"PaintCheck"], accentColor);
        }
            break;
            
        case TGInstantPagePresentationThemeGray: {
            UIColor *accentColor = UIColorRGB(0xc7c7c7);
            _brightnessSliderView.trackColor = accentColor;
            _brightnessSliderView.backColor = UIColorRGB(0xb6b6b6);
            
            _checkView.image = TGTintedImage([UIImage imageNamed:@"PaintCheck"], accentColor);
        }
            break;
            
        case TGInstantPagePresentationThemeBlack: {
            UIColor *accentColor = UIColorRGB(0xbfc0c2);
            _brightnessSliderView.trackColor = accentColor;
            _brightnessSliderView.backColor = UIColorRGB(0xa6a6a6);
            
            _checkView.image = TGTintedImage([UIImage imageNamed:@"PaintCheck"], accentColor);
            
            panelColor = UIColorRGB(0x232323);
            separatorColor = UIColorRGB(0x1b1b1b);
            textColor = UIColorRGB(0x878787);
            selectionColor = UIColorRGB(0x4c4c4c);
        }
            break;
            
        default: {
            UIColor *accentColor = TGAccentColor();
            _brightnessSliderView.trackColor = accentColor;
            _brightnessSliderView.backColor = UIColorRGB(0xb7b7b7);
            _checkView.image = TGTintedImage([UIImage imageNamed:@"PaintCheck"], accentColor);
        }
            break;
    }
    
    _fontSliderView.trackColor = _brightnessSliderView.trackColor;
    _fontSliderView.backColor = _brightnessSliderView.backColor;
    
    UIImage *arrowImage = [UIImage imageNamed:@"InstantViewSettingsArrow"];
    
    if ([panelColor isEqual:[UIColor whiteColor]]) {
        _panelView.backgroundColor = [UIColor whiteColor];
        
        _brightnessMinIconView.image = [UIImage imageNamed:@"InstantViewBrightnessMinIcon"];
        _brightnessMaxIconView.image = [UIImage imageNamed:@"InstantViewBrightnessMaxIcon"];
        
        _fontMinIconView.image = [UIImage imageNamed:@"InstantViewFontMinIcon"];
        _fontMaxIconView.image = [UIImage imageNamed:@"InstantViewFontMaxIcon"];
        
        _whiteColorView.isOnDarkBackground = false;
    } else {
        _panelView.backgroundColor = panelColor;
        arrowImage = TGTintedImage(arrowImage, panelColor);
        
        UIColor *tintColor = UIColorRGB(0xa0a0a0);
        _brightnessMinIconView.image = TGTintedImage([UIImage imageNamed:@"InstantViewBrightnessMinIcon"], tintColor);
        _brightnessMaxIconView.image = TGTintedImage([UIImage imageNamed:@"InstantViewBrightnessMaxIcon"], tintColor);
        
        _fontMinIconView.image = TGTintedImage([UIImage imageNamed:@"InstantViewFontMinIcon"], tintColor);
        _fontMaxIconView.image = TGTintedImage([UIImage imageNamed:@"InstantViewFontMaxIcon"], tintColor);
        
        _whiteColorView.isOnDarkBackground = true;
    }
    
    _brightnessSliderView.backgroundColor = panelColor;
    _fontSliderView.backgroundColor = panelColor;
    _autoThemeLabel.backgroundColor = panelColor;
    _autoThemeLabel.textColor = textColor;
    
    _sansSerifFontButton.highlightBackgroundColor = selectionColor;
    [_sansSerifFontButton setTitleColor:textColor];
    
    _serifFontButton.highlightBackgroundColor = selectionColor;
    [_serifFontButton setTitleColor:textColor];
    
    if ([separatorColor isEqual:[UIColor clearColor]]) {
        separatorColor = UIColorRGB(0xc8c7cb);
        _fontSeparatorLineView.image = _separatorLineImage;
        _fontShortSeparatorLineView.image = _separatorLineImage;
        _themeSeparatorLineView.image = _separatorLineImage;
        _firstSepartorView.image = _separatorImage;
        _secondSepartorView.image = _separatorImage;
    } else {
        _fontSeparatorLineView.image = _separatorLineDarkImage;
        _fontShortSeparatorLineView.image = _separatorLineDarkImage;
        _themeSeparatorLineView.image = _separatorLineDarkImage;
        _firstSepartorView.image = nil;
        _firstSepartorView.backgroundColor = separatorColor;
        _secondSepartorView.image = nil;
        _secondSepartorView.backgroundColor = separatorColor;
    }
    
    if (presentation.initialTheme == TGInstantPagePresentationThemeBlack) {
        _autoThemeWrapperView.layer.rasterizationScale = TGScreenScaling();
        _autoThemeWrapperView.layer.shouldRasterize = true;
        
        [_autoThemeSwitch setOn:false animated:animated];
        _autoThemeSwitch.userInteractionEnabled = false;
        
        _autoThemeWrapperView.alpha = 0.5f;

    } else {
        [_autoThemeSwitch setOn:_autoNight animated:animated];
        _autoThemeSwitch.userInteractionEnabled = true;
        
        _autoThemeWrapperView.alpha = 1.0f;
    }
    
    void (^completionBlock)(BOOL) = ^(BOOL finished) {
        if (finished && presentation.initialTheme != TGInstantPagePresentationThemeBlack) {
            _autoThemeWrapperView.layer.shouldRasterize = false;
        }
    };

    if (animated) {
        [UIView transitionWithView:_arrowView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _arrowView.image = arrowImage;
        } completion:nil];
        
        [UIView animateWithDuration:0.15 animations:^{
            snapshotView.alpha = 0.0f;
        } completion:^(__unused BOOL finished) {
            [snapshotView removeFromSuperview];
          
            completionBlock(finished);
        }];
    } else {
        _arrowView.image = arrowImage;
        completionBlock(true);
    }
}

- (void)layoutSubviews {
    CGFloat panelHeight = MIN(338.0f, self.frame.size.height - 76.0f);
    
    _panelWrapperView.frame = CGRectMake(self.frame.size.width - 106.0f - 196.0f, 42.0f + 28.0f, _panelWrapperView.frame.size.width, panelHeight);
    _arrowView.frame = CGRectMake((self.frame.size.width - _settingsButtonPosition.x - 15.0f) - _panelWrapperView.frame.origin.x, -13.0f, _arrowView.frame.size.width, _arrowView.frame.size.height);
    
    _panelView.frame = CGRectMake(0.0f, 0.0f, _panelView.frame.size.width, panelHeight);
    _scrollView.frame = CGRectMake(0.0f, 0.0f, _scrollView.frame.size.width, panelHeight);
    
    _brightnessMinIconView.frame = CGRectMake(16.0f, 24.0f, _brightnessMinIconView.frame.size.width, _brightnessMinIconView.frame.size.height);
    _brightnessMaxIconView.frame = CGRectMake(_panelView.frame.size.width - _brightnessMaxIconView.frame.size.width - 13.0f, 21.0f, _brightnessMaxIconView.frame.size.width, _brightnessMaxIconView.frame.size.height);
    
    _fontMinIconView.frame = CGRectMake(18.0f, 93.0f, _fontMinIconView.frame.size.width, _fontMinIconView.frame.size.height);
    _fontMaxIconView.frame = CGRectMake(_panelView.frame.size.width - _fontMaxIconView.frame.size.width - 14.0f, 89.0f, _fontMaxIconView.frame.size.width, _fontMaxIconView.frame.size.height);
    
    _checkView.frame = CGRectMake(17.0f, CGRectGetMaxY(_fontSeparatorLineView.frame) + (_fontSerif ? 44.0f : 0.0f) + 17.0f, _checkView.frame.size.width, _checkView.frame.size.height);
}

@end
