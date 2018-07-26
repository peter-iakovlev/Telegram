#import "TGAppearanceAutoNightController.h"

#import <LegacyComponents/TGDateUtils.h>
#import <LegacyComponents/TGLocationSignals.h>
#import <LegacyComponents/TGMenuSheetController.h>

#import "TGLegacyComponentsContext.h"
#import "TGPresentation.h"

#import "EDSunriseSet.h"
#import "TGScreenBrightnessSignals.h"

#import "TGNightBluePresentationPallete.h"
#import "TGNightPresentationPallete.h"

#import "TGHeaderCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGCheckCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGButtonCollectionItem.h"
#import "TGBrightnessCollectionItem.h"

#import "TGTimePickerItemView.h"

@interface TGAppearanceAutoNightController () <CLLocationManagerDelegate>
{
    id<SDisposable> _disposable;
    id<SDisposable> _brightnessDisposable;
    
    CLLocationManager *_locationManager;
    SMetaDisposable *_locationDisposable;
    
    TGCheckCollectionItem *_disabledItem;
    TGCheckCollectionItem *_scheduledItem;
    TGCheckCollectionItem *_automaticItem;
    
    TGCollectionMenuSection *_scheduledSection;
    TGSwitchCollectionItem *_useLocationItem;
    TGVariantCollectionItem *_fromItem;
    TGVariantCollectionItem *_toItem;
    TGVariantCollectionItem *_updateLocationItem;
    TGCommentCollectionItem *_locationCommentItem;
    
    TGCollectionMenuSection *_automaticSection;
    TGBrightnessCollectionItem *_brightnessItem;
    TGCommentCollectionItem *_brightnessCommentItem;
    
    TGCollectionMenuSection *_preferredThemeSection;
    TGCheckCollectionItem *_nightBlueItem;
    TGCheckCollectionItem *_nightItem;
    
    int32_t _scheduleStartTime;
    int32_t _scheduleEndTime;
    
    CGFloat _previousLatitude;
    CGFloat _previousLongitude;
}
@end

@implementation TGAppearanceAutoNightController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"AutoNightTheme.Title");
        
        _disabledItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"AutoNightTheme.Disabled") action:@selector(disabledPressed)];
        _scheduledItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"AutoNightTheme.Scheduled") action:@selector(scheduledPressed)];
        _automaticItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"AutoNightTheme.Automatic") action:@selector(automaticPressed)];
        
        __weak TGAppearanceAutoNightController *weakSelf = self;
        TGCollectionMenuSection *modeSection = [[TGCollectionMenuSection alloc] initWithItems:@[_disabledItem, _scheduledItem, _automaticItem]];
        UIEdgeInsets topSectionInsets = modeSection.insets;
        topSectionInsets.top = 32.0f;
        modeSection.insets = topSectionInsets;
        [self.menuSections addSection:modeSection];
        
        _useLocationItem = [[TGSwitchCollectionItem alloc] initWithTitle:TGLocalized(@"AutoNightTheme.UseSunsetSunrise") isOn:false];
        _useLocationItem.toggled = ^(bool value, __unused TGSwitchCollectionItem *item)
        {
            [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
            {
                return value ? [preferences sunsetSunriseModeWithLatitude:preferences.latitude longitude:preferences.longitude cachedLocationName:preferences.cachedLocationName] : [preferences scheduledModeWithStart:preferences.scheduleStart end:preferences.scheduleEnd];
            }];
        };
        _scheduledSection = [[TGCollectionMenuSection alloc] initWithItems:@[[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"AutoNightTheme.ScheduleSection")], _useLocationItem]];
        
        _fromItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"AutoNightTheme.ScheduledFrom") action:@selector(fromPressed)];
        _fromItem.deselectAutomatically = true;
        
        _toItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"AutoNightTheme.ScheduledTo") action:@selector(toPressed)];
        _toItem.deselectAutomatically = true;
        
        _updateLocationItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"AutoNightTheme.UpdateLocation" ) action:@selector(updateLocationPressed)];
        _updateLocationItem.deselectAutomatically = true;
        _updateLocationItem.hideArrow = true;
        _updateLocationItem.titleColor = self.presentation.pallete.collectionMenuAccentColor;
        
        _locationCommentItem = [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"AutoNightTheme.LocationHelp")];
        _locationCommentItem.inhibitInteraction = true;
        
        _brightnessItem = [[TGBrightnessCollectionItem alloc] init];
        _brightnessItem.valueChanged = ^(CGFloat value)
        {
            __strong TGAppearanceAutoNightController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updateBrightness:value];
        };
        _brightnessItem.interactionEnded = ^
        {
            __strong TGAppearanceAutoNightController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
                {
                    return [preferences brightnessModeWithThreshold:strongSelf->_brightnessItem.value];
                }];
            }
        };
        _brightnessCommentItem = [[TGCommentCollectionItem alloc] initWithText:TGLocalized(@"AutoNightTheme.AutomaticHelp")];
        _brightnessCommentItem.inhibitInteraction = true;
        _automaticSection = [[TGCollectionMenuSection alloc] initWithItems:@[[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"AutoNightTheme.AutomaticSection")], _brightnessItem, _brightnessCommentItem]];
        
        _preferredThemeSection = [[TGCollectionMenuSection alloc] initWithItems:@
        [
         [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"AutoNightTheme.PreferredTheme")],
         _nightBlueItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.ThemeNightBlue") action:@selector(nightBluePressed)],
         _nightItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.ThemeNight") action:@selector(nightPressed)]
        ]];
        
        _disposable = [[[TGPresentation autoNightPreferences] reduceLeftWithPassthrough:@false with:^id(id initial, id value, void (^passthrough)(id))
        {
            passthrough(@{ @"value" :value, @"animated": @([initial boolValue]) });
            return @true;
        }] startWithNext:^(NSDictionary *next)
        {
            TGPresentationAutoNightPreferences *preferences = next[@"value"];
            bool animated = [next[@"animated"] boolValue];
            
            __strong TGAppearanceAutoNightController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf updateSections:preferences animated:animated];
        }];
        
        _brightnessDisposable = [[TGScreenBrightnessSignals brightnessSignal] startWithNext:^(NSNumber  *next)
        {
            __strong TGAppearanceAutoNightController *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf->_brightnessItem.markerValue = next.doubleValue;
        }];
    }
    return self;
}

- (void)dealloc
{
    [_disposable dispose];
    [_brightnessDisposable dispose];
}

- (void)disabledPressed
{
    [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
    {
        return [preferences disabledAutoNight];
    }];
}

- (void)scheduledPressed
{
    [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
    {
        return [preferences scheduledModeWithStart:preferences.scheduleStart end:preferences.scheduleEnd];
    }];
}

- (void)automaticPressed
{
    [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
    {
        return [preferences brightnessModeWithThreshold:preferences.brightnessThreshold];
    }];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    _updateLocationItem.titleColor = self.presentation.pallete.collectionMenuAccentColor;
}

- (void)updateSections:(TGPresentationAutoNightPreferences *)preferences animated:(bool)animated
{
    _disabledItem.isChecked = preferences.mode == TGPresentationAutoNightModeDisabled;
    _scheduledItem.isChecked = preferences.mode == TGPresentationAutoNightModeScheduled || preferences.mode == TGPresentationAutoNightModeSunsetSunrise;
    _automaticItem.isChecked = preferences.mode == TGPresentationAutoNightModeBrightness;
    
    _useLocationItem.isOn = preferences.mode == TGPresentationAutoNightModeSunsetSunrise;
    
    bool scheduledShouldBeVisible = preferences.mode == TGPresentationAutoNightModeScheduled || preferences.mode == TGPresentationAutoNightModeSunsetSunrise;
    bool automaticShouldBeVisible = preferences.mode == TGPresentationAutoNightModeBrightness;
    bool changed = false;
    
    if (animated)
        [self.menuSections beginRecordingChanges];
    
    NSUInteger scheduledSectionIndex = [self.menuSections.sections indexOfObject:_scheduledSection];
    bool scheduledSectionVisible = scheduledSectionIndex != NSNotFound;
    
    NSUInteger automaticSectionIndex = [self.menuSections.sections indexOfObject:_automaticSection];
    bool automaticSectionVisible = automaticSectionIndex != NSNotFound;
    
    NSUInteger preferredSectionIndex = [self.menuSections.sections indexOfObject:_preferredThemeSection];
    bool preferredSectionVisible = preferredSectionIndex != NSNotFound;
    bool preferredSectionShouldBeVisible = scheduledShouldBeVisible || automaticShouldBeVisible;
    if (preferredSectionVisible && !preferredSectionShouldBeVisible) {
        preferredSectionVisible = false;
        [self.menuSections deleteSection:[self.menuSections.sections indexOfObject:_preferredThemeSection]];
        changed = true;
    }

    if (scheduledSectionVisible) {
        if (!scheduledShouldBeVisible) {
            scheduledSectionVisible = false;
            
            if (automaticShouldBeVisible)
            {
                [self.menuSections replaceSection:[self.menuSections.sections indexOfObject:_scheduledSection] withSection:_automaticSection];
                automaticSectionVisible = true;
            }
            else
            {
                NSUInteger indexOfLocationItem = [self.menuSections.sections[scheduledSectionIndex] indexOfItem:_updateLocationItem];
                if (indexOfLocationItem != NSNotFound)
                {
                    [self.menuSections deleteItemFromSection:scheduledSectionIndex atIndex:indexOfLocationItem + 1];
                    [self.menuSections deleteItemFromSection:scheduledSectionIndex atIndex:indexOfLocationItem];
                }
                
                [self.menuSections deleteSection:[self.menuSections.sections indexOfObject:_scheduledSection]];
            }
            changed = true;
        }
    } else {
        if (scheduledShouldBeVisible) {
            scheduledSectionVisible = true;
            if (automaticSectionVisible)
            {
                [self.menuSections replaceSection:[self.menuSections.sections indexOfObject:_automaticSection] withSection:_scheduledSection];
                automaticSectionVisible = false;
            }
            else
            {
                [self.menuSections insertSection:_scheduledSection atIndex:1];
            }
            changed = true;
            
            scheduledSectionIndex = [self.menuSections.sections indexOfObject:_scheduledSection];
        }
    }
    
    if (automaticSectionVisible) {
        if (!automaticShouldBeVisible) {
            automaticSectionVisible = false;
            [self.menuSections deleteSection:[self.menuSections.sections indexOfObject:_automaticSection]];
            changed = true;
        }
    } else {
        if (automaticShouldBeVisible) {
            automaticSectionVisible = true;
            [self.menuSections insertSection:_automaticSection atIndex:1];
            changed = true;
        }
    }
    
    if (!preferredSectionVisible && preferredSectionShouldBeVisible) {
        preferredSectionVisible = true;
        [self.menuSections insertSection:_preferredThemeSection atIndex:2];
        changed = true;
    }
    
    if (scheduledSectionVisible) {
        bool locationVisible = _useLocationItem.isOn;
        NSUInteger indexOfLocationItem = [self.menuSections.sections[scheduledSectionIndex] indexOfItem:_updateLocationItem];
        NSUInteger indexOfFromItem = [self.menuSections.sections[scheduledSectionIndex] indexOfItem:_fromItem];
        if (indexOfLocationItem != NSNotFound) {
            if (!locationVisible) {
                [self.menuSections deleteItemFromSection:scheduledSectionIndex atIndex:indexOfLocationItem + 1];
                [self.menuSections deleteItemFromSection:scheduledSectionIndex atIndex:indexOfLocationItem];
                changed = true;
            }
        } else {
            if (locationVisible) {
                if (indexOfFromItem != NSNotFound) {
                    [self.menuSections deleteItemFromSection:scheduledSectionIndex atIndex:indexOfFromItem + 1];
                    [self.menuSections deleteItemFromSection:scheduledSectionIndex atIndex:indexOfFromItem];
                    
                    indexOfFromItem = NSNotFound;
                }
                
                [self.menuSections insertItem:_updateLocationItem toSection:scheduledSectionIndex atIndex:2];
                [self.menuSections insertItem:_locationCommentItem toSection:scheduledSectionIndex atIndex:3];
                changed = true;
            }
        }
        
        if (indexOfFromItem != NSNotFound) {
            if (locationVisible) {
                [self.menuSections deleteItemFromSection:scheduledSectionIndex atIndex:indexOfFromItem + 1];
                [self.menuSections deleteItemFromSection:scheduledSectionIndex atIndex:indexOfFromItem];
                changed = true;
            }
        } else {
            if (!locationVisible) {
                [self.menuSections insertItem:_fromItem toSection:scheduledSectionIndex atIndex:2];
                [self.menuSections insertItem:_toItem toSection:scheduledSectionIndex atIndex:3];
                changed = true;
            }
        }
    }
    
    if (animated)
        [self.menuSections commitRecordedChanges:self.collectionView];
    else if (changed)
        [self.collectionView reloadData];
    
    _brightnessItem.value = preferences.brightnessThreshold;
    
    if (preferences.mode == TGPresentationAutoNightModeSunsetSunrise) {
        if (fabs(preferences.latitude) < DBL_EPSILON && fabs(preferences.longitude) < DBL_EPSILON)
            [self updateLocationPressed];
        else if (preferences.cachedLocationName == nil)
            [self updateLocationNameWithLatitude:preferences.latitude longitude:preferences.longitude];
        
        [self updateSunsetSunriseTimeLatitude:preferences.latitude longitude:preferences.longitude];
        
        _updateLocationItem.variant = preferences.cachedLocationName;
    }
    else if (preferences.mode == TGPresentationAutoNightModeScheduled) {
        [_locationDisposable setDisposable:nil];
        
        _scheduleStartTime = preferences.scheduleStart;
        _scheduleEndTime = preferences.scheduleEnd;
        
        int hours = (int)preferences.scheduleStart / 3600;
        int minutes = ((int)preferences.scheduleStart / 60) % 60;
        _fromItem.variant = [TGDateUtils stringForShortTimeWithHours:hours minutes:minutes];
        
        hours = (int)preferences.scheduleEnd / 3600;
        minutes = ((int)preferences.scheduleEnd / 60) % 60;
        _toItem.variant = [TGDateUtils stringForShortTimeWithHours:hours minutes:minutes];
    }
    else if (preferences.mode == TGPresentationAutoNightModeBrightness) {
        [_locationDisposable setDisposable:nil];
        [self updateBrightness:preferences.brightnessThreshold];
    } else {
        [_locationDisposable setDisposable:nil];
    }
    
    _nightBlueItem.isChecked = preferences.preferredPalette == 3;
    _nightItem.isChecked = preferences.preferredPalette == 2;
    
    if (changed)
    {
        TGDispatchAfter(0.3, dispatch_get_main_queue(), ^
        {
            [self.collectionView reloadData];
        });
    }
}

- (void)updateBrightness:(CGFloat)brightness
{
    _brightnessCommentItem.text = [NSString stringWithFormat:TGLocalized(@"AutoNightTheme.AutomaticHelp"), [NSString stringWithFormat:@"%d", (int)(brightness * 100.0f)]];
}

- (CGRect)frameForItem:(TGCollectionItem *)item
{
    for (TGCollectionItemView *itemView in self.collectionView.visibleCells)
    {
        if (![itemView isKindOfClass:[TGCollectionItemView class]])
            continue;
        
        if (itemView.boundItem == item)
            return [itemView convertRect:itemView.bounds toView:self.view];
    }
    return CGRectZero;
}

- (void)fromPressed
{
    __weak TGAppearanceAutoNightController *weakSelf = self;
    [self presentTimePickerWithValue:_scheduleStartTime title:TGLocalized(@"AutoNightTheme.ScheduledFrom") sourceRect:^CGRect
    {
        __strong TGAppearanceAutoNightController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return [strongSelf frameForItem:strongSelf->_fromItem];
    } completion:^(int value)
    {
        [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
        {
            return [preferences scheduledModeWithStart:value end:preferences.scheduleEnd];
        }];
    }];
}

- (void)toPressed
{
    __weak TGAppearanceAutoNightController *weakSelf = self;
    [self presentTimePickerWithValue:_scheduleEndTime title:TGLocalized(@"AutoNightTheme.ScheduledTo") sourceRect:^CGRect
    {
        __strong TGAppearanceAutoNightController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return [strongSelf frameForItem:strongSelf->_toItem];
    } completion:^(int value)
    {
        [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
        {
            return [preferences scheduledModeWithStart:preferences.scheduleStart end:value];
        }];
    }];
}

- (void)presentTimePickerWithValue:(int)value title:(NSString *)title sourceRect:(CGRect (^)(void))sourceRect completion:(void (^)(int))completion
{
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.narrowInLandscape = true;
    controller.sourceRect = sourceRect;
    controller.permittedArrowDirections = (UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown);
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    
    TGMenuSheetTitleItemView *titleItem = [[TGMenuSheetTitleItemView alloc] initWithTitle:title subtitle:nil];
    [itemViews addObject:titleItem];
    
    TGTimePickerItemView *timerItem = [[TGTimePickerItemView alloc] initWithValue:value];
    [itemViews addObject:timerItem];
    
    __weak TGMenuSheetController *weakController = controller;
    __weak TGTimePickerItemView *weakTimeItem = timerItem;
    TGMenuSheetButtonItemView *doneItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Done") type:TGMenuSheetButtonTypeSend action:^
    {
        __strong TGTimePickerItemView *strongTimeItem = weakTimeItem;
        if (strongTimeItem != nil)
            completion([TGAppearanceAutoNightController timeForDate:strongTimeItem.dateValue]);
        
        __strong TGMenuSheetController *strongController = weakController;
        [strongController dismissAnimated:true];
    }];
    [itemViews addObject:doneItem];
    
    [controller setItemViews:itemViews animated:false];
    [controller presentInViewController:self sourceView:self.view animated:true];
}

- (void)nightBluePressed
{
    [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
    {
        return [preferences preferredPalette:3];
    }];
    
    _nightBlueItem.isChecked = true;
    _nightItem.isChecked = false;
}

- (void)nightPressed
{
    [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
    {
        return [preferences preferredPalette:2];
    }];
    
    _nightBlueItem.isChecked = false;
    _nightItem.isChecked = true;
}

- (void)updateLocationPressed
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    _locationManager.activityType = CLActivityTypeOther;
    
    if (iosMajorVersion() >= 8)
        [_locationManager requestAlwaysAuthorization];
    
    if (iosMajorVersion() >= 9)
        [_locationManager requestLocation];
    else
        [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)__unused manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorized)
    {
        if (iosMajorVersion() >= 9)
            [_locationManager requestLocation];
        else
            [_locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)__unused manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (locations.count == 0)
        return;
    
    CLLocationCoordinate2D coordinate = locations.firstObject.coordinate;
    [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
    {
        return [preferences sunsetSunriseModeWithLatitude:coordinate.latitude longitude:coordinate.longitude cachedLocationName:nil];
    }];
    
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    _locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)__unused manager didFailWithError:(NSError *)__unused error
{
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    _locationManager = nil;
}

- (void)updateLocationNameWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
{
    if (_locationDisposable == nil)
        _locationDisposable = [[SMetaDisposable alloc] init];
    
    [_locationDisposable setDisposable:[[TGLocationSignals cityForCoordinate:CLLocationCoordinate2DMake(latitude, longitude)] startWithNext:^(NSString *next)
    {
        [TGPresentation updateAutoNightPreferences:^TGPresentationAutoNightPreferences *(TGPresentationAutoNightPreferences *preferences)
        {
            return [preferences sunsetSunriseModeWithLatitude:latitude longitude:longitude cachedLocationName:next];
        }];
    }]];
}

- (void)updateSunsetSunriseTimeLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
{
    NSString *sunsetString = nil;
    NSString *sunriseString = nil;
    
    if (fabs(latitude) < DBL_EPSILON && fabs(longitude) < DBL_EPSILON)
    {
        sunsetString = TGLocalized(@"AutoNightTheme.NotAvailable");
        sunriseString = TGLocalized(@"AutoNightTheme.NotAvailable");
    }
    else if (fabs(latitude - _previousLatitude) > DBL_EPSILON || fabs(longitude - _previousLongitude) > DBL_EPSILON)
    {
        EDSunriseSet *calculator = [[EDSunriseSet alloc] initWithDate:[NSDate date] timezone:[NSTimeZone localTimeZone] latitude:latitude longitude:longitude];
        sunsetString = [TGDateUtils stringForShortTime:(int)(calculator.sunset.timeIntervalSince1970)];
        sunriseString = [TGDateUtils stringForShortTime:(int)(calculator.sunrise.timeIntervalSince1970)];
        
        _previousLatitude = latitude;
        _previousLongitude = longitude;
    }
    else
    {
        return;
    }
    
    _locationCommentItem.text = [NSString stringWithFormat:TGLocalized(@"AutoNightTheme.LocationHelp"), sunsetString, sunriseString];
}

+ (int)timeForDate:(NSDate *)date
{
    return (int)[date timeIntervalSince1970];
}

@end
