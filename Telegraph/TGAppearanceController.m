#import "TGAppearanceController.h"

#import "TGLegacyComponentsContext.h"

#import "TGHeaderCollectionItem.h"
#import "TGDisclosureActionCollectionItem.h"
#import "TGFontSizeCollectionItem.h"
#import "TGCheckCollectionItem.h"
#import "TGSwitchCollectionItem.h"
#import "TGAppearancePreviewCollectionItem.h"
#import "TGAppearanceColorCollectionItem.h"

#import "TGAppearanceColorPickerItemView.h"

#import "TGPresentation.h"
#import "TGDefaultPresentationPallete.h"
#import "TGDayPresentationPallete.h"
#import "TGNightPresentationPallete.h"
#import "TGNightBluePresentationPallete.h"

#import "TGWallpaperManager.h"
#import <LegacyComponents/TGColorWallpaperInfo.h>
#import "TGMessageViewModel.h"

#import "TGWallpaperListController.h"
#import "TGAppearanceAutoNightController.h"

@interface TGAppearanceController () <ASWatcher>
{
    TGFontSizeCollectionItem *_sizeItem;
    
    TGAppearanceColorCollectionItem *_colorItem;
    TGCollectionMenuSection *_previewSection;
    TGAppearancePreviewCollectionItem *_previewItem;
    TGCheckCollectionItem *_dayClassicItem;
    TGCheckCollectionItem *_dayItem;
    TGCheckCollectionItem *_nightItem;
    TGCheckCollectionItem *_nightBlueItem;
    
    TGDisclosureActionCollectionItem *_autoNightItem;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGAppearanceController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.title = TGLocalized(@"Appearance.Title");
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:nil action:nil];
        
        TGCollectionMenuSection *fontSection = [[TGCollectionMenuSection alloc] initWithItems:@
        [
         [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.TextSize")],
         _sizeItem = [[TGFontSizeCollectionItem alloc] init]
        ]];
        
        __weak TGAppearanceController *weakSelf = self;
        _sizeItem.valueChanged = ^(int32_t value)
        {
            __strong TGAppearanceController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                CGFloat size = [strongSelf fontSizeForPosition:value];
                [TGPresentation setFontSize:size];
                TGUpdateMessageViewModelLayoutConstants(size);
                [strongSelf->_previewItem refreshMetrics];
            }
        };
        
        [[[TGPresentation fontSizeSignal] take:1] startWithNext:^(NSNumber *next)
        {
            __strong TGAppearanceController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                int32_t position = [strongSelf positionForFontSize:next.floatValue];
                [strongSelf->_sizeItem setValue:position];
                
                TGUpdateMessageViewModelLayoutConstants(next.floatValue);
            }
        }];
        
        UIEdgeInsets topSectionInsets = fontSection.insets;
        topSectionInsets.top = 32.0f;
        fontSection.insets = topSectionInsets;
        [self.menuSections addSection:fontSection];
        
        _previewItem = [[TGAppearancePreviewCollectionItem alloc] init],
        _previewItem.heightChanged = ^ {
            __strong TGAppearanceController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf.collectionLayout invalidateLayout];
                [strongSelf.collectionView layoutSubviews];
            }
        };
        _previewItem.messages = [self messages];
        
        _colorItem = [[TGAppearanceColorCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.AccentColor") action:@selector(accentColorPressed)];
        _colorItem.deselectAutomatically = true;
        
        _autoNightItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.AutoNightTheme") action:@selector(autoNightPressed)];
        
        TGDisclosureActionCollectionItem *backgroundItem = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Settings.ChatBackground") action:@selector(wallpapersPressed)];
        backgroundItem.ignoreSeparatorInset = true;
        _previewSection = [[TGCollectionMenuSection alloc] initWithItems:@
        [
         [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.Preview")],
         _previewItem,
         backgroundItem
        ]];
        [self.menuSections addSection:_previewSection];
        
        [self updateColorItem:TGPresentation.currentSavedPallete];
        
        TGCollectionMenuSection *themeSection = [[TGCollectionMenuSection alloc] initWithItems:@
        [
         [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.ColorTheme")],
         _dayClassicItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.ThemeDayClassic") action:@selector(dayClassicPressed)],
         _dayItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.ThemeDay") action:@selector(dayPressed)],
         _nightBlueItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.ThemeNightBlue") action:@selector(nightBluePressed)],
         _nightItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Appearance.ThemeNight") action:@selector(nightPressed)]
        ]];
        [self.menuSections addSection:themeSection];
        
        [self updateSelection];
        
        [ActionStageInstance() watchForPaths:@[@"/tg/assets/currentWallpaperInfo"] watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (iosMajorVersion() < 8)
    {
        [_previewItem refreshMetrics];
        [self.collectionLayout invalidateLayout];
        [self.collectionView layoutSubviews];
    }
}

- (void)wallpapersPressed
{
    TGWallpaperListController *controller = [[TGWallpaperListController alloc] init];
    controller.presentation = self.presentation;
    [self.navigationController pushViewController:controller animated:true];
}

- (void)accentColorPressed
{
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    controller.dismissesByOutsideTap = true;
    controller.narrowInLandscape = true;
    controller.hasSwipeGesture = true;
    
    __weak TGMenuSheetController *weakController = controller;
    __weak TGAppearanceController *weakSelf = self;
    TGAppearanceColorPickerItemView *colorItem = [[TGAppearanceColorPickerItemView alloc] initWithCurrentColor:self.presentation.pallete.accentColor];
    colorItem.colorSelected = ^(UIColor *color)
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController != nil)
            [strongController dismissAnimated:true];
        
        __strong TGAppearanceController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGDayPresentationPallete *pallete = [TGDayPresentationPallete dayPalleteWithAccentColor:color];
            [strongSelf setPallete:pallete applyColorWallpaper:false];
        }
    };
    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController != nil)
            [strongController dismissAnimated:true];
    }];
    [controller setItemViews:@[colorItem, cancelItem]];
    
    controller.sourceRect = ^CGRect{
        __strong TGAppearanceController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return [strongSelf frameForItem:strongSelf->_colorItem];
    };
    
    [controller presentInViewController:self sourceView:self.view animated:true];
}

- (void)autoNightPressed
{
    TGAppearanceAutoNightController *controller = [[TGAppearanceAutoNightController alloc] init];
    controller.presentation = self.presentation;
    [self.navigationController pushViewController:controller animated:true];
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

- (void)updateColorItem:(TGPresentationPallete *)pallete
{
    bool colorVisible = [pallete isKindOfClass:[TGDayPresentationPallete class]];
    bool autoNightVisible = [pallete isKindOfClass:[TGDefaultPresentationPallete class]];
    bool changed = false;
    
    if (colorVisible)
        _colorItem.color = pallete.accentColor;
    
    NSUInteger indexOfColorItem = [_previewSection indexOfItem:_colorItem];
    if (indexOfColorItem != NSNotFound) {
        if (!colorVisible) {
            [_previewSection deleteItemAtIndex:indexOfColorItem];
            changed = true;
        }
    } else {
        if (colorVisible) {
            indexOfColorItem = 3;
            [_previewSection insertItem:_colorItem atIndex:3];
            changed = true;
        }
    }
    
    NSUInteger indexOfAutoNightItem = [_previewSection indexOfItem:_autoNightItem];
    if (indexOfAutoNightItem != NSNotFound) {
        if (!autoNightVisible) {
            [_previewSection deleteItemAtIndex:indexOfAutoNightItem];
            changed = true;
        }
    } else {
        if (autoNightVisible) {
            NSUInteger targetIndex = indexOfColorItem != NSNotFound ? indexOfColorItem + 1 : 3;
            [_previewSection insertItem:_autoNightItem atIndex:targetIndex];
            changed = true;
        }
    }
    
    if (changed)
        [self.collectionView reloadData];
}

- (void)dayClassicPressed
{
    if (_dayClassicItem.isChecked)
        return;
    
    [self setPallete:[TGDefaultPresentationPallete new] applyColorWallpaper:false];
    
    TGWallpaperInfo *info = [[TGWallpaperManager instance] builtinWallpaperList].firstObject;
    [[TGWallpaperManager instance] setCurrentWallpaperWithInfo:info];
}

- (void)dayPressed
{
    if (_dayItem.isChecked)
        return;

    TGPresentationPallete *pallete = [TGDayPresentationPallete new];
    [self setPallete:pallete applyColorWallpaper:true];
}

- (void)nightPressed
{
    if (_nightItem.isChecked)
        return;
    
    TGPresentationPallete *pallete = [TGNightPresentationPallete new];
    [self setPallete:pallete applyColorWallpaper:true];
}

- (void)nightBluePressed
{
    if (_nightBlueItem.isChecked)
        return;
    
    TGPresentationPallete *pallete = [TGNightBluePresentationPallete new];
    [self setPallete:pallete applyColorWallpaper:true];
}

- (void)setPallete:(TGPresentationPallete *)pallete applyColorWallpaper:(bool)applyColorWallpaper
{
    if (applyColorWallpaper)
    {
        TGColorWallpaperInfo *info = [[TGColorWallpaperInfo alloc] initWithColor:TGColorHexCode(pallete.backgroundColor)];
        [[TGWallpaperManager instance] setCurrentWallpaperWithInfo:info];
    }
    
    [TGPresentation switchToPallete:pallete];
    [self updateSelection];
    
    [self updateColorItem:pallete];
    
    if (TGIsPad() || iosMajorVersion() < 8)
    {
        [self setNeedsStatusBarAppearanceUpdate];
        return;
    }
    
    UIView *snapshotView = [self.navigationController.view snapshotViewAfterScreenUpdates:false];
    [self.navigationController.view addSubview:snapshotView];
    
    [UIView animateWithDuration:0.2 animations:^
    {
        snapshotView.alpha = 0.0f;
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(__unused BOOL finished)
    {
        [snapshotView removeFromSuperview];
    }];
}

- (void)updateSelection
{
    TGPresentationPallete *savedPallete = TGPresentation.currentSavedPallete;
    _dayClassicItem.isChecked = [savedPallete isMemberOfClass:[TGDefaultPresentationPallete class]];
    _dayItem.isChecked = [savedPallete isMemberOfClass:[TGDayPresentationPallete class]];
    _nightItem.isChecked = [savedPallete isMemberOfClass:[TGNightPresentationPallete class]];
    _nightBlueItem.isChecked = [savedPallete isMemberOfClass:[TGNightBluePresentationPallete class]];
}

- (NSArray *)messages
{
    TGUser *replyAuthor = [[TGUser alloc] init];
    replyAuthor.firstName = TGLocalized(@"Appearance.PreviewReplyAuthor");
    replyAuthor.uid = 2;
    
    TGMessage *replyMessage = [[TGMessage alloc] init];
    replyMessage.mid = 1;
    replyMessage.fromUid = 2;
    replyMessage.text = TGLocalized(@"Appearance.PreviewReplyText");
    replyMessage.date = 60 * (60 * 18 + 19);
    
    TGReplyMessageMediaAttachment *replyMessageAttachment = [[TGReplyMessageMediaAttachment alloc] init];
    replyMessageAttachment.replyMessageId = replyMessage.mid;
    replyMessageAttachment.replyMessage = replyMessage;
    
    TGMessage *firstMessage = [[TGMessage alloc] init];
    firstMessage.mid = 2;
    firstMessage.fromUid = 1;
    firstMessage.text = TGLocalized(@"Appearance.PreviewIncomingText");
    firstMessage.date = 60 * (60 * 18 + 20);
    firstMessage.mediaAttachments = @[replyMessageAttachment];
    
    TGMessage *secondMessage = [[TGMessage alloc] init];
    secondMessage.mid = 3;
    secondMessage.fromUid = 2;
    secondMessage.outgoing = true;
    secondMessage.text = TGLocalized(@"Appearance.PreviewOutgoingText");
    secondMessage.date = 60 * (60 * 18 + 20);
    
    return @[ secondMessage, firstMessage ];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)__unused resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/assets/currentWallpaperInfo"])
    {
        TGDispatchOnMainThread(^
        {
            [_previewItem updateWallpaper];
            if ([self.presentation.pallete isKindOfClass:[TGDayPresentationPallete class]])
                [_previewItem reset];
        });
    }
}

+ (NSArray *)fontSizes
{
    return @[ @14.0f, @15.0f, @16.0f, @17.0f, @19.0f, @23.0f, @26.0f ];
}

- (CGFloat)fontSizeForPosition:(int32_t)position
{
    if (position < 0 || position > (int32_t)[TGAppearanceController fontSizes].count)
        return 17.0f;
    
    return [[TGAppearanceController fontSizes][position] floatValue];
}

- (int32_t)positionForFontSize:(CGFloat)fontSize
{
    int32_t bestIndex = 3;
    CGFloat bestDelta = FLT_MAX;
    
    NSArray *fontSizes = [TGAppearanceController fontSizes];
    for (int32_t i = 0; i < (int32_t)fontSizes.count; i++)
    {
        CGFloat size = [fontSizes[i] floatValue];
        CGFloat delta = (CGFloat)fabs(size - fontSize);
        if (delta < bestDelta)
        {
            bestDelta = delta;
            bestIndex = i;
        }
    }
    
    return bestIndex;
}

@end
