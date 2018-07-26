#import "TGPresentation.h"
#import "TGDefaultPresentationPallete.h"
#import "TGDayPresentationPallete.h"
#import "TGNightPresentationPallete.h"
#import "TGNightBluePresentationPallete.h"

#import "TGMediaStoreContext.h"
#import "TGAppDelegate.h"
#import "TGWallpaperManager.h"

#import "EDSunriseSet.h"

#import "TGModernConversationControllerDynamicTypeSignals.h"
#import "TGScreenBrightnessSignals.h"

#import <LegacyComponents/TGImageBlur.h>
#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGFont.h>

#import <LegacyComponents/TGColorWallpaperInfo.h>
#import <LegacyComponents/TGBuiltinWallpaperInfo.h>
#import <LegacyComponents/TGNavigationBar.h>
#import <LegacyComponents/TGSearchBar.h>
#import <LegacyComponents/TGMenuSheetController.h>
#import <LegacyComponents/TGStickerKeyboardTabPanel.h>
#import <LegacyComponents/TGCheckButtonView.h>
#import <LegacyComponents/TGMediaAssetsController.h>
#import <LegacyComponents/TGLocationMapViewController.h>
#import <LegacyComponents/TGModernConversationInputMicButton.h>
#import <LegacyComponents/TGModernConversationAssociatedInputPanel.h>

@interface TGPresentationState : NSObject <NSCoding>

@property (nonatomic, readonly) int32_t pallete;
@property (nonatomic, readonly) int32_t userInfo;
@property (nonatomic, readonly) int32_t fontSize;

- (instancetype)initWithPallete:(int32_t)pallete userInfo:(int32_t)userInfo fontSize:(int32_t)fontSize;

@end

@implementation TGPresentation

- (TGNavigationBarPallete *)navigationBarPallete
{
    return [TGNavigationBarPallete palleteWithBackgroundColor:self.pallete.barBackgroundColor separatorColor:self.pallete.barSeparatorColor titleColor:self.pallete.navigationTitleColor tintColor:self.pallete.navigationButtonColor];
}

- (TGSearchBarPallete *)searchBarPallete
{
    return [TGSearchBarPallete palleteWithDark:self.pallete.isDark backgroundColor:self.pallete.searchBarBackgroundColor highContrastBackgroundColor:self.pallete.searchBarMergedBackgroundColor textColor:self.pallete.searchBarTextColor placeholderColor:self.pallete.searchBarPlaceholderColor clearIcon:self.images.searchClearIcon barBackgroundColor:self.pallete.barBackgroundColor barSeparatorColor:self.pallete.barSeparatorColor plainBackgroundColor:self.pallete.backgroundColor accentColor:self.pallete.accentColor accentContrastColor:self.pallete.accentContrastColor menuBackgroundColor:self.pallete.menuBackgroundColor segmentedControlBackgroundImage:self.images.segmentedControlBackgroundImage segmentedControlSelectedImage:self.images.segmentedControlSelectedImage segmentedControlHighlightedImage:self.images.segmentedControlHighlightedImage segmentedControlDividerImage:self.images.segmentedControlDividerImage];
}

- (TGSearchBarPallete *)keyboardSearchBarPallete
{
    return [TGSearchBarPallete palleteWithDark:self.pallete.isDark backgroundColor:self.pallete.chatInputKeyboardSearchBarColor highContrastBackgroundColor:self.pallete.chatInputKeyboardSearchBarColor textColor:self.pallete.searchBarTextColor placeholderColor:self.pallete.searchBarPlaceholderColor clearIcon:self.images.searchClearIcon barBackgroundColor:self.pallete.barBackgroundColor barSeparatorColor:[UIColor clearColor] plainBackgroundColor:[UIColor clearColor] accentColor:self.pallete.accentColor accentContrastColor:self.pallete.accentContrastColor menuBackgroundColor:self.pallete.menuBackgroundColor segmentedControlBackgroundImage:self.images.segmentedControlBackgroundImage segmentedControlSelectedImage:self.images.segmentedControlSelectedImage segmentedControlHighlightedImage:self.images.segmentedControlHighlightedImage segmentedControlDividerImage:self.images.segmentedControlDividerImage];
}

- (TGMenuSheetPallete *)menuSheetPallete
{
    return [TGMenuSheetPallete palleteWithDark:self.pallete.isDark backgroundColor:self.pallete.menuBackgroundColor selectionColor:self.pallete.menuSelectionColor separatorColor:self.pallete.menuSeparatorColor accentColor:self.pallete.menuAccentColor destructiveColor:self.pallete.menuDestructiveColor textColor:self.pallete.menuTextColor secondaryTextColor:self.pallete.menuSecondaryTextColor spinnerColor:self.pallete.menuSpinnerColor badgeTextColor:self.pallete.accentContrastColor badgeImage:self.images.shareBadgeImage cornersImage:self.images.menuCornersImage];
}

- (TGStickerKeyboardPallete *)stickerKeyboardPallete
{
    return [TGStickerKeyboardPallete palleteWithBackgroundColor:self.pallete.barBackgroundColor separatorColor:self.pallete.chatInputKeyboardBorderColor selectionColor:self.pallete.chatInputSelectionColor gifIcon:self.images.chatStickersGifIcon trendingIcon:self.images.chatStickersTrendingIcon favoritesIcon:self.images.chatStickersFavoritesIcon recentIcon:self.images.chatStickersRecentIcon settingsIcon:self.images.chatStickersSettingsIcon badge:self.images.chatStickersBadge badgeTextColor:self.pallete.accentContrastColor];
}

- (TGCheckButtonPallete *)checkButtonPallete
{
    return [TGCheckButtonPallete palleteWithDefaultBackgroundColor:self.pallete.checkButtonBackgroundColor accentBackgroundColor:self.pallete.accentColor defaultBorderColor:self.pallete.checkButtonBorderColor mediaBorderColor:[UIColor whiteColor] chatBorderColor:self.pallete.checkButtonChatBorderColor checkColor:self.pallete.accentContrastColor blueColor:self.pallete.checkButtonBlueColor barBackgroundColor:self.pallete.menuBackgroundColor];
}

- (TGMediaAssetsPallete *)mediaAssetsPallete
{
    return [TGMediaAssetsPallete palleteWithDark:self.pallete.isDark backgroundColor:self.pallete.backgroundColor selectionColor:self.pallete.selectionColor separatorColor:self.pallete.separatorColor textColor:self.pallete.textColor secondaryTextColor:self.pallete.secondaryTextColor accentColor:self.pallete.accentColor barBackgroundColor:self.pallete.barBackgroundColor barSeparatorColor:self.pallete.barSeparatorColor navigationTitleColor:self.pallete.navigationTitleColor badge:self.images.mediaBadgeImage badgeTextColor:self.pallete.accentContrastColor sendIconImage:self.images.chatInputSendIcon maybeAccentColor:self.pallete.maybeAccentColor];
}

- (TGLocationPallete *)locationPallete
{
    return [TGLocationPallete palleteWithBackgroundColor:self.pallete.menuBackgroundColor selectionColor:self.pallete.selectionColor separatorColor:self.pallete.separatorColor textColor:self.pallete.textColor secondaryTextColor:self.pallete.secondaryTextColor accentColor:self.pallete.accentColor destructiveColor:self.pallete.destructiveColor locationColor:self.pallete.locationAccentColor liveLocationColor:self.pallete.locationLiveColor iconColor:self.pallete.accentContrastColor sectionHeaderBackgroundColor:self.pallete.menuSectionHeaderBackgroundColor sectionHeaderTextColor:self.pallete.sectionHeaderTextColor searchBarPallete:self.searchBarPallete avatarPlaceholder:[self.images avatarPlaceholderWithDiameter:48.0f]];
}

- (TGModernConversationInputMicPallete *)micButtonPallete
{
    return [TGModernConversationInputMicPallete palleteWithDark:self.pallete.isDark buttonColor:self.pallete.chatInputSendButtonColor iconColor:self.pallete.chatInputSendButtonIconColor backgroundColor:self.pallete.barBackgroundColor borderColor:self.pallete.barSeparatorColor lockColor:self.pallete.secondaryTextColor textColor:self.pallete.textColor secondaryTextColor:self.pallete.secondaryTextColor recordingColor:self.pallete.chatInputRecordingColor];
}

- (TGConversationAssociatedInputPanelPallete *)associatedInputPanelPallete
{
    return [TGConversationAssociatedInputPanelPallete palleteWithDark:self.pallete.isDark backgroundColor:self.pallete.backgroundColor separatorColor:self.pallete.separatorColor selectionColor:self.pallete.selectionColor barBackgroundColor:self.pallete.barBackgroundColor barSeparatorColor:self.pallete.barSeparatorColor textColor:self.pallete.textColor secondaryTextColor:self.pallete.secondaryTextColor accentColor:self.pallete.accentColor placeholderBackgroundColor:nil placeholderIconColor:nil avatarPlaceholder:[self.images avatarPlaceholderWithDiameter:32.0f] closeIcon:self.images.replyCloseIcon largeCloseIcon:self.images.pinCloseIcon];
}

- (TGImageBorderPallete *)imageBorderPallete
{
    return [TGImageBorderPallete palleteWithBorderColor:self.pallete.chatImageBorderColor shadowColor:self.pallete.chatImageBorderShadowColor];
}

static TGPresentation *currentPresentation;
static TGPresentationState *currentState;
static SPipe *presentationPipe;
static CGFloat fontSize = 17.0f;
static bool useDynamicTypeFontSize = false;
static id<SDisposable> dynamicTypeDisposable;
static SPipe *fontPipe;

static TGPresentationAutoNightPreferences *autoNightPreferences;
static SPipe *autoNightPreferencesPipe;
static id<SDisposable> autoNightDisposable;

- (instancetype)initWithPallete:(TGPresentationPallete *)pallete
{
    self = [super init];
    if (self != nil)
    {
        _currentId = arc4random();
        _pallete = pallete;
        _images = [TGPresentationImages imagesWithPallete:pallete];
    }
    return self;
}

+ (instancetype)presentationWithPallete:(TGPresentationPallete *)pallete
{
    return [[self alloc] initWithPallete:pallete];
}

+ (instancetype)defaultPresentation
{
    return [self presentationWithPallete:[[TGDefaultPresentationPallete alloc] init]];
}

+ (NSString *)documentsPath
{
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (iosMajorVersion() >= 8)
        {
            NSString *groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
            
            NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupName];
            if (groupURL != nil)
            {
                NSString *documentsPath = [[groupURL path] stringByAppendingPathComponent:@"Documents"];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:true attributes:nil error:NULL];
                
                path = documentsPath;
            }
            else
                path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
        }
        else
            path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
    });
    return path;
}

+ (NSString *)presentationPath
{
    return [[self documentsPath] stringByAppendingPathComponent:@"presentation.dat"];
}

+ (NSString *)autoNightPreferencesPath
{
    return [[self documentsPath] stringByAppendingPathComponent:@"autonight.dat"];
}

+ (int32_t)indexForPallete:(TGPresentationPallete *)pallete
{
    if ([pallete isKindOfClass:[TGDayPresentationPallete class]])
        return 1;
    if ([pallete isKindOfClass:[TGNightPresentationPallete class]])
        return 2;
    if ([pallete isKindOfClass:[TGNightBluePresentationPallete class]])
        return 3;
    
    return 0;
}

+ (TGPresentationPallete *)nightPalleteWithIndex:(int32_t)index
{
    switch (index)
    {
        case 2:
            return [[TGNightPresentationPallete alloc] init];
        default:
            return [[TGNightBluePresentationPallete alloc] init];
    }
}

+ (TGPresentationPallete *)palleteWithState:(TGPresentationState *)state
{
    if (state == nil)
        return [[TGDefaultPresentationPallete alloc] init];
    
    switch (state.pallete)
    {
        case 1:
            return [TGDayPresentationPallete dayPalleteWithAccentColor:UIColorRGB(state.userInfo)];
        case 2:
            return [[TGNightPresentationPallete alloc] init];
        case 3:
            return [[TGNightBluePresentationPallete alloc] init];
        default:
            return [[TGDefaultPresentationPallete alloc] init];
    }
}

+ (CGFloat)fontSizeWithState:(TGPresentationState *)state
{
    if (state == nil || state.fontSize == 0)
        return 0.0f;
    
    return state.fontSize;
}

+ (TGPresentationState *)loadState
{
    NSData *data = [NSData dataWithContentsOfFile:[self presentationPath]];
    if (data.length == 0)
        return nil;
    
    TGPresentationState *state = nil;
    @try {
        state = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *e) {
        
    }
    return state;
}

+ (void)saveCurrentState
{
    int32_t userInfo = [currentPresentation.pallete isKindOfClass:[TGDayPresentationPallete class]] ? TGColorHexCode(currentPresentation.pallete.accentColor) : 0;
    currentState = [[TGPresentationState alloc] initWithPallete:[self indexForPallete:currentPresentation.pallete] userInfo:userInfo fontSize:useDynamicTypeFontSize ? 0 : (int32_t)fontSize];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:currentState];
    [data writeToFile:[self presentationPath] atomically:true];
}

+ (TGPresentationAutoNightPreferences *)loadAutoNightPreferences
{
    NSData *data = [NSData dataWithContentsOfFile:[self autoNightPreferencesPath]];
    if (data.length == 0)
        return nil;
    
    TGPresentationAutoNightPreferences *state = nil;
    @try {
        state = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *e) {
        
    }
    return state;
}

+ (NSNumber *)isAutoNightActivated
{
    if (autoNightPreferences.mode == TGPresentationAutoNightModeDisabled)
        return nil;
    
    __block bool value = false;
    [[[self autoNightThemeSignal] take:1] startWithNext:^(id next)
    {
        value = [next int32Value] != 0;
    }];
    
    return @(value);
}

+ (SSignal *)autoNightPreferences
{
    return [[SSignal single:autoNightPreferences] then:autoNightPreferencesPipe.signalProducer()];
}

+ (void)updateAutoNightPreferences:(TGPresentationAutoNightPreferences *(^)(TGPresentationAutoNightPreferences *))updateBlock
{
    autoNightPreferences = updateBlock(autoNightPreferences);
    autoNightPreferencesPipe.sink(autoNightPreferences);
    
    [self saveAutoNightPreferences];
}

+ (void)saveAutoNightPreferences
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:autoNightPreferences];
    [data writeToFile:[self autoNightPreferencesPath] atomically:true];
}

+ (SSignal *)scheduledAutoNightSignal:(int32_t)startTime endTime:(int32_t)endTime
{
    bool (^check)(void) = ^bool
    {
        NSDate *currentDate = [NSDate date];
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:currentDate];
        
        [components setHour:0];
        [components setMinute:0];
        [components setSecond:0];
        
        NSDate *startDate = [cal dateFromComponents:components];
        NSTimeInterval secs = [currentDate timeIntervalSinceDate:startDate];
        
        if (startTime > endTime)
            return secs >= startTime || secs < endTime;
        else
            return secs >= startTime && secs < endTime;
    };
    
    SSignal *timerSignal = [[[[SSignal single:nil] map:^NSNumber *(__unused id value)
    {
        return @(check());
    }] then:[[SSignal complete] delay:60.0 onQueue:[SQueue mainQueue]]] restart];
    
    return [[SSignal single:@(check())] then:timerSignal];
}

+ (int)_timeForDate:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:date];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *startDate = [cal dateFromComponents:components];
    NSTimeInterval secs = [date timeIntervalSinceDate:startDate];
    return (int)secs;
}

+ (SSignal *)autoNightThemeSignal
{
    return [[self autoNightPreferences] mapToSignal:^SSignal *(TGPresentationAutoNightPreferences *preferences)
    {
        if (preferences.mode == TGPresentationAutoNightModeBrightness)
        {
            SSignal *decisionSignal = [[TGScreenBrightnessSignals brightnessSignal] map:^NSNumber *(NSNumber *brightness)
            {
                return @(brightness.doubleValue < preferences.brightnessThreshold ? preferences.preferredPalette : 0);
            }];
            
            SSignal *throttledSignal = [[[decisionSignal ignoreRepeated] reduceLeftWithPassthrough:nil with:^id(id value, id next, void (^passthrough)(id))
            {
                if (value == nil)
                    passthrough([SSignal single:next]);
                else
                    passthrough([[SSignal single:next] delay:2.0 onQueue:[SQueue mainQueue]]);
                
                return @true;
            }] switchToLatest];
            
            return [TGAppDelegateInstance.isActive mapToSignal:^SSignal *(NSNumber *active)
            {
                if (active.boolValue)
                    return throttledSignal;
                else
                    return [SSignal never];
            }];
        }
        else if (preferences.mode == TGPresentationAutoNightModeScheduled)
        {
            return [[self scheduledAutoNightSignal:preferences.scheduleStart endTime:preferences.scheduleEnd] map:^id(NSNumber *value) {
                return @(value.boolValue ? preferences.preferredPalette : 0);
            }];
        }
        else if (preferences.mode == TGPresentationAutoNightModeSunsetSunrise)
        {
            EDSunriseSet *calculator = [[EDSunriseSet alloc] initWithDate:[NSDate date] timezone:[NSTimeZone localTimeZone] latitude:preferences.latitude longitude:preferences.longitude];
            int32_t start = [self _timeForDate:calculator.sunset];
            int32_t end = [self _timeForDate:calculator.sunrise];
            return [[self scheduledAutoNightSignal:start endTime:end] map:^id(NSNumber *value) {
                return @(value.boolValue ? preferences.preferredPalette : 0);
            }];
        }
        else
        {
            return [SSignal single:@0];
        }
    }];
}

+ (void)load
{
    currentState = [self loadState];
    if (currentState == nil)
        currentState = [[TGPresentationState alloc] initWithPallete:0 userInfo:0 fontSize:0];
    presentationPipe = [[SPipe alloc] init];
    
    currentPresentation = [[TGPresentation alloc] initWithPallete:[self palleteWithState:currentState]];
    
    fontSize = currentState.fontSize;
    fontPipe = [[SPipe alloc] init];
    if (fontSize < FLT_EPSILON)
        [self _resetFontSize];
    
    autoNightPreferences = [self loadAutoNightPreferences];
    if (autoNightPreferences == nil)
        autoNightPreferences = [TGPresentationAutoNightPreferences defaultAutoNight];
    autoNightPreferencesPipe = [[SPipe alloc] init];
    
    SSignal *startupDelaySignal = [[SSignal complete] delay:0.2 onQueue:[SQueue mainQueue]];
    autoNightDisposable = [[[startupDelaySignal then:[self autoNightThemeSignal]] ignoreRepeated] startWithNext:^(NSNumber *next)
    {
        if (next.integerValue > 0)
            [self switchToPallete:[self nightPalleteWithIndex:next.int32Value] temporary:true];
        else
            [self switchToPallete:[self currentSavedPallete] temporary:true];
    }];
}

+ (void)switchToPallete:(TGPresentationPallete *)pallete
{
    [self switchToPallete:pallete temporary:false];
}

+ (void)switchToPallete:(TGPresentationPallete *)pallete temporary:(bool)temporary
{
    [TGCheckButtonView resetCache];
    [[TGMediaStoreContext instance] clearMemoryCache];
    
    currentPresentation = [[TGPresentation alloc] initWithPallete:pallete];
    presentationPipe.sink(currentPresentation);

    [self refreshUIAppearance];
    
    if (!temporary)
    {
        [self saveCurrentState];
    }
    else
    {
        TGWallpaperInfo *savedWallpaper = [[TGWallpaperManager instance] savedWallpaperInfo];
        bool isDefaultWallpaper = [savedWallpaper isKindOfClass:[TGColorWallpaperInfo class]] || ([savedWallpaper isKindOfClass:[TGBuiltinWallpaperInfo class]] && [(TGBuiltinWallpaperInfo *)savedWallpaper isDefault]);
        
        if (pallete.isDark && isDefaultWallpaper)
        {
            TGColorWallpaperInfo *info = [[TGColorWallpaperInfo alloc] initWithColor:TGColorHexCode(pallete.backgroundColor)];
            [[TGWallpaperManager instance] setCurrentWallpaperWithInfo:info temporary:true];
        }
        else
        {
            [[TGWallpaperManager instance] restoreCurrentWallpaper];
        }
        
        TGViewController *rootController = TGAppDelegateInstance.rootController;
        UIView *snapshotView = [rootController.view snapshotViewAfterScreenUpdates:false];
        [rootController.view addSubview:snapshotView];
        
        [UIView animateWithDuration:0.2 animations:^
        {
            snapshotView.alpha = 0.0f;
            [rootController setNeedsStatusBarAppearanceUpdate];
        } completion:^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
        }];
    }
}

+ (void)refreshUIAppearance
{
    if (iosMajorVersion() < 7)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 30), false, 0.0f);
        UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIBarButtonItem *item = [UIBarButtonItem appearanceWhenContainedIn:[TGNavigationBar class], nil];
        
        [item setBackgroundImage:transparentImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        UIImage *backImage = TGTintedImage([UIImage imageNamed:@"NavigationBackButton.png"], TGPresentation.current.pallete.navigationButtonColor);
        UIImage *backHighlightedImage = TGTintedImage([UIImage imageNamed:@"NavigationBackButton_Highlighted.png"], TGPresentation.current.pallete.navigationButtonColor);
        UIImage *backLandscapeImage = TGTintedImage([UIImage imageNamed:@"NavigationBackButtonLandscape.png"], TGPresentation.current.pallete.navigationButtonColor);
        UIImage *backLandscapeHighlightedImage = TGTintedImage([UIImage imageNamed:@"NavigationBackButtonLandscape_Highlighted.png"], TGPresentation.current.pallete.navigationButtonColor);
        [item setBackButtonBackgroundImage:[backImage stretchableImageWithLeftCapWidth:(int)(backImage.size.width) topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [item setBackButtonBackgroundImage:[backHighlightedImage stretchableImageWithLeftCapWidth:(int)(backHighlightedImage.size.width) topCapHeight:0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [item setBackButtonBackgroundImage:[backLandscapeImage stretchableImageWithLeftCapWidth:(int)(backLandscapeImage.size.width) topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        [item setBackButtonBackgroundImage:[backLandscapeHighlightedImage stretchableImageWithLeftCapWidth:(int)(backLandscapeHighlightedImage.size.width) topCapHeight:0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
        [item setBackButtonTitlePositionAdjustment:UIOffsetMake(5, -1) forBarMetrics:UIBarMetricsDefault];
        [item setBackButtonTitlePositionAdjustment:UIOffsetMake(5, -3) forBarMetrics:UIBarMetricsLandscapePhone];
        
        [item setTitlePositionAdjustment:UIOffsetMake(0, 1) forBarMetrics:UIBarMetricsDefault];
        
        [item setTitleTextAttributes:@{UITextAttributeTextColor:TGPresentation.current.pallete.accentColor, UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(16.0f)} forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{UITextAttributeTextColor: [TGPresentation.current.pallete.accentColor colorWithAlphaComponent:0.4f], UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(16.0f)} forState:UIControlStateHighlighted];
        
        [[TGNavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor: TGPresentation.current.pallete.navigationTitleColor, UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGBoldSystemFontOfSize(17.0f)}];
        [[TGNavigationBar appearance] setTitleVerticalPositionAdjustment:(TGIsRetina() ? 0.5f : 0.0f) forBarMetrics:UIBarMetricsDefault];
        [[TGNavigationBar appearance] setTitleVerticalPositionAdjustment:-1.0f forBarMetrics:UIBarMetricsLandscapePhone];
    }
    else
    {
        [[UITextField appearance] setTintColor:TGPresentation.current.pallete.maybeAccentColor];
        [[UITextView appearance] setTintColor:TGPresentation.current.pallete.maybeAccentColor];
    }
}

+ (TGPresentation *)current
{
    return currentPresentation;
}

+ (TGPresentationPallete *)currentSavedPallete
{
    return [self palleteWithState:currentState];
}

+ (SSignal *)signal
{
    return [[SSignal single:[self current]] then:presentationPipe.signalProducer()];
}

+ (SSignal *)fontSizeSignal
{
    return [[SSignal single:@(fontSize)] then:fontPipe.signalProducer()];
}

+ (CGFloat)fontSize
{
    return fontSize;
}

+ (void)setFontSize:(CGFloat)newFontSize
{
    fontSize = newFontSize;
    useDynamicTypeFontSize = false;
    
    fontPipe.sink(@(fontSize));
    
    [self saveCurrentState];
}

+ (void)resetFontSize
{
    [self _resetFontSize];
    fontPipe.sink(@(fontSize));
    
    [self saveCurrentState];
}

+ (void)_resetFontSize
{
    if (iosMajorVersion() >= 7)
    {
        useDynamicTypeFontSize = true;
        fontSize = [UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize;
        if (dynamicTypeDisposable == nil)
        {
            dynamicTypeDisposable = [[TGModernConversationControllerDynamicTypeSignals dynamicTypeBaseFontPointSize] startWithNext:^(NSNumber *next)
            {
                if (useDynamicTypeFontSize)
                {
                    fontSize = next.floatValue;
                    fontPipe.sink(next);
                }
            }];
        }
    }
    else
    {
        fontSize = 17.0f;
    }
}

@end


@implementation UIColor (HSB)

- (UIColor *)colorWithHueMultiplier:(CGFloat)hueMultiplier saturationMultiplier:(CGFloat)saturationMultiplier brightnessMultiplier:(CGFloat)brightnessMultiplier
{
    CGFloat currentHue = 0.0f;
    CGFloat currentSaturation = 0.0f;
    CGFloat currentBrightness = 0.0f;
    CGFloat currentAlpha = 0.0f;
    
    if ([self getHue:&currentHue saturation:&currentSaturation brightness:&currentBrightness alpha:&currentAlpha])
    {
        return [UIColor colorWithHue:currentHue * hueMultiplier saturation:currentSaturation * saturationMultiplier brightness:currentBrightness * brightnessMultiplier alpha:currentAlpha];
    }
    else
    {
        return self;
    }
}

- (int32_t)hexCode
{
    CGFloat red, green, blue, alpha;
    if (![self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        if (![self getWhite:&red alpha:&alpha]) {
            return 0;
        }
        green = red;
        blue = red;
    }
    
    uint32_t redInt = (uint32_t)(red * 255 + 0.5);
    uint32_t greenInt = (uint32_t)(green * 255 + 0.5);
    uint32_t blueInt = (uint32_t)(blue * 255 + 0.5);
    
    return (redInt << 16) | (greenInt << 8) | blueInt;
}

@end


@implementation TGPresentationState

- (instancetype)initWithPallete:(int32_t)pallete userInfo:(int32_t)userInfo fontSize:(int32_t)fontSize
{
    self = [super init];
    if (self != nil)
    {
        _pallete = pallete;
        _userInfo = userInfo;
        _fontSize = fontSize;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _pallete = [aDecoder decodeInt32ForKey:@"p"];
        _userInfo = [aDecoder decodeInt32ForKey:@"u"];
        _fontSize = [aDecoder decodeInt32ForKey:@"f"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:_pallete forKey:@"p"];
    [aCoder encodeInt32:_userInfo forKey:@"u"];
    [aCoder encodeInt32:_fontSize forKey:@"f"];
}

@end

const CGFloat TGPresentationDefaultBrightnessThreshold = 0.25f;

@implementation TGPresentationAutoNightPreferences

- (instancetype)initWithMode:(TGPresentationAutoNightMode)mode brightnessThreshold:(CGFloat)brightnessThreshold scheduleStart:(int32_t)scheduleStart scheduleEnd:(int32_t)scheduleEnd latitude:(CGFloat)latitude longitude:(CGFloat)longitude cachedLocationName:(NSString *)cachedLocationName preferredPalette:(int32_t)preferredPallete
{
    self = [super init];
    if (self != nil)
    {
        _mode = mode;
        _brightnessThreshold = brightnessThreshold;
        _scheduleStart = scheduleStart;
        _scheduleEnd = scheduleEnd;
        _latitude = latitude;
        _longitude = longitude;
        _cachedLocationName = cachedLocationName;
        _preferredPalette = preferredPallete;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        _mode = [aDecoder decodeInt32ForKey:@"m"];
        _brightnessThreshold = [aDecoder decodeDoubleForKey:@"b"];
        _scheduleStart = [aDecoder decodeInt32ForKey:@"ss"];
        _scheduleEnd = [aDecoder decodeInt32ForKey:@"se"];
        _latitude = [aDecoder decodeDoubleForKey:@"lat"];
        _longitude = [aDecoder decodeDoubleForKey:@"lon"];
        _cachedLocationName = [aDecoder decodeObjectForKey:@"loc"];
        _preferredPalette = [aDecoder decodeInt32ForKey:@"p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:_mode forKey:@"m"];
    [aCoder encodeDouble:_brightnessThreshold forKey:@"b"];
    [aCoder encodeInt32:_scheduleStart forKey:@"ss"];
    [aCoder encodeInt32:_scheduleEnd forKey:@"se"];
    [aCoder encodeDouble:_latitude forKey:@"lat"];
    [aCoder encodeDouble:_longitude forKey:@"lon"];
    [aCoder encodeObject:_cachedLocationName forKey:@"loc"];
    [aCoder encodeInt32:_preferredPalette forKey:@"p"];
}

+ (instancetype)defaultAutoNight
{
    return [[TGPresentationAutoNightPreferences alloc] initWithMode:TGPresentationAutoNightModeDisabled brightnessThreshold:TGPresentationDefaultBrightnessThreshold scheduleStart:79200 scheduleEnd:32400 latitude:0.0 longitude:0.0 cachedLocationName:nil preferredPalette:3];
}

- (instancetype)disabledAutoNight
{
    return [[TGPresentationAutoNightPreferences alloc] initWithMode:TGPresentationAutoNightModeDisabled brightnessThreshold:TGPresentationDefaultBrightnessThreshold scheduleStart:self.scheduleStart scheduleEnd:self.scheduleEnd latitude:self.latitude longitude:self.longitude cachedLocationName:self.cachedLocationName preferredPalette:self.preferredPalette];
}

- (instancetype)brightnessModeWithThreshold:(CGFloat)threshold
{
    return [[TGPresentationAutoNightPreferences alloc] initWithMode:TGPresentationAutoNightModeBrightness brightnessThreshold:threshold scheduleStart:self.scheduleStart scheduleEnd:self.scheduleEnd latitude:self.latitude longitude:self.longitude cachedLocationName:self.cachedLocationName preferredPalette:self.preferredPalette];
}

- (instancetype)scheduledModeWithStart:(int32_t)start end:(int32_t)end
{
    return [[TGPresentationAutoNightPreferences alloc] initWithMode:TGPresentationAutoNightModeScheduled brightnessThreshold:TGPresentationDefaultBrightnessThreshold scheduleStart:start scheduleEnd:end latitude:self.latitude longitude:self.longitude cachedLocationName:self.cachedLocationName preferredPalette:self.preferredPalette];
}

- (instancetype)sunsetSunriseModeWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude cachedLocationName:(NSString *)cachedLocationName
{
    return [[TGPresentationAutoNightPreferences alloc] initWithMode:TGPresentationAutoNightModeSunsetSunrise brightnessThreshold:TGPresentationDefaultBrightnessThreshold scheduleStart:self.scheduleStart scheduleEnd:self.scheduleEnd latitude:latitude longitude:longitude cachedLocationName:cachedLocationName preferredPalette:self.preferredPalette];
}

- (instancetype)preferredPalette:(int32_t)palette
{
    return [[TGPresentationAutoNightPreferences alloc] initWithMode:self.mode brightnessThreshold:self.brightnessThreshold scheduleStart:self.scheduleStart scheduleEnd:self.scheduleEnd latitude:self.latitude longitude:self.longitude cachedLocationName:self.cachedLocationName preferredPalette:palette];
}

@end
