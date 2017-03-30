//
//  STPTheme.m
//  Stripe
//
//  Created by Jack Flintermann on 5/3/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPTheme.h"
#import "STPColorUtils.h"

@interface STPTheme()
@end

static UIColor *STPThemeDefaultPrimaryBackgroundColor;
static UIColor *STPThemeDefaultSecondaryBackgroundColor;
static UIColor *STPThemeDefaultPrimaryForegroundColor;
static UIColor *STPThemeDefaultSecondaryForegroundColor;
static UIColor *STPThemeDefaultAccentColor;
static UIColor *STPThemeDefaultErrorColor;
static UIFont  *STPThemeDefaultFont;
static UIFont  *STPThemeDefaultMediumFont;

#define FAUXPAS_IGNORED_ON_LINE(...)

@implementation STPTheme

+ (void)initialize {
    STPThemeDefaultPrimaryBackgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:245.0f/255.0f alpha:1];
    STPThemeDefaultSecondaryBackgroundColor = [UIColor whiteColor];
    STPThemeDefaultPrimaryForegroundColor = [UIColor colorWithRed:43.0f/255.0f green:43.0f/255.0f blue:45.0f/255.0f alpha:1];
    STPThemeDefaultSecondaryForegroundColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:147.0f/255.0f alpha:1];
    STPThemeDefaultAccentColor = [UIColor colorWithRed:0 green:122.0f/255.0f blue:1 alpha:1];
    STPThemeDefaultErrorColor = [UIColor colorWithRed:1 green:72.0f/255.0f blue:68.0f/255.0f alpha:1];
    STPThemeDefaultFont = [UIFont systemFontOfSize:17];
    
    if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        STPThemeDefaultMediumFont = [UIFont systemFontOfSize:17.0f weight:0.2f] ?: [UIFont boldSystemFontOfSize:17]; FAUXPAS_IGNORED_ON_LINE(APIAvailability);
    } else {
        STPThemeDefaultMediumFont = [UIFont boldSystemFontOfSize:17];
    }
}

+ (STPTheme *)defaultTheme {
    static STPTheme  *STPThemeDefaultTheme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        STPThemeDefaultTheme = [self new];
    });
    return STPThemeDefaultTheme;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _primaryBackgroundColor = STPThemeDefaultPrimaryBackgroundColor;
        _secondaryBackgroundColor = STPThemeDefaultSecondaryBackgroundColor;
        _primaryForegroundColor = STPThemeDefaultPrimaryForegroundColor;
        _secondaryForegroundColor = STPThemeDefaultSecondaryForegroundColor;
        _accentColor = STPThemeDefaultAccentColor;
        _errorColor = STPThemeDefaultErrorColor;
        _font = STPThemeDefaultFont;
        _emphasisFont = STPThemeDefaultMediumFont;
        _translucentNavigationBar = NO;
        // This is a sentinel value (the equivalent of nil).
        // If unset, we return the default computed bar style
        _barStyle = -1;
    }
    return self;
}

- (UIColor *)primaryBackgroundColor {
    return _primaryBackgroundColor ?: STPThemeDefaultPrimaryBackgroundColor;
}

- (UIColor *)secondaryBackgroundColor {
    return _secondaryBackgroundColor ?: STPThemeDefaultSecondaryBackgroundColor;
}

- (UIColor *)tertiaryBackgroundColor {
	CGFloat hue;
	CGFloat saturation;
	CGFloat brightness;
	CGFloat alpha;
	[self.primaryBackgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation brightness:(brightness - 0.09f) alpha:alpha];
}

- (UIColor *)primaryForegroundColor {
    return _primaryForegroundColor ?: STPThemeDefaultPrimaryForegroundColor;
}

- (UIColor *)secondaryForegroundColor {
    return _secondaryForegroundColor ?: STPThemeDefaultSecondaryForegroundColor;
}

- (UIColor *)tertiaryForegroundColor {
    return [self.primaryForegroundColor colorWithAlphaComponent:0.25f];
}

- (UIColor *)quaternaryBackgroundColor {
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [self.primaryBackgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation brightness:(brightness - 0.03f) alpha:alpha];
}

- (UIColor *)accentColor {
    return _accentColor ?: STPThemeDefaultAccentColor;
}

- (UIColor *)errorColor {
    return _errorColor ?: STPThemeDefaultErrorColor;
}

- (UIFont *)font {
    return _font ?: STPThemeDefaultFont;
}

- (UIFont *)emphasisFont {
    return _emphasisFont ?: STPThemeDefaultMediumFont;
}

- (UIFont *)smallFont {
    return [self.font fontWithSize:self.font.pointSize - 2];
}

- (UIFont *)largeFont {
    return [self.font fontWithSize:self.font.pointSize + 15];
}

- (UIBarStyle)barStyleForColor:(UIColor *)color {
    if ([STPColorUtils colorIsBright:color]) {
        return UIBarStyleDefault;
    }
    else {
        return UIBarStyleBlack;
    }
}

- (UIBarStyle)barStyle {
    UIBarStyle defaultStyle = [self barStyleForColor:self.primaryBackgroundColor];
    if (_barStyle < 0) {
        return defaultStyle;
    }
    else {
        return _barStyle;
    }
}

- (id)copyWithZone:(__unused NSZone *)zone {
    STPTheme *copyTheme = [self.class new];
    copyTheme.primaryBackgroundColor = self.primaryBackgroundColor;
    copyTheme.secondaryBackgroundColor = self.secondaryBackgroundColor;
    copyTheme.primaryForegroundColor = self.primaryForegroundColor;
    copyTheme.secondaryForegroundColor = self.secondaryForegroundColor;
    copyTheme.accentColor = self.accentColor;
    copyTheme.errorColor = self.errorColor;
    copyTheme.font = self.font;
    copyTheme.emphasisFont = self.emphasisFont;
    return copyTheme;
}

@end
