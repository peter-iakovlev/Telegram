#import <UIKit/UIKit.h>

typedef enum
{
    TGPhotoEditorNoneTab    = 0,
    TGPhotoEditorCropTab    = 1 << 0,
    TGPhotoEditorToolsTab   = 1 << 1,
    TGPhotoEditorCaptionTab = 1 << 2,
    TGPhotoEditorRotateTab  = 1 << 3
} TGPhotoEditorTab;

@interface TGPhotoToolbarView : UIView

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

@property (nonatomic, copy) void(^cancelPressed)(void);
@property (nonatomic, copy) void(^donePressed)(void);

@property (nonatomic, copy) void(^doneLongPressed)(id sender);

@property (nonatomic, copy) void(^tabPressed)(TGPhotoEditorTab tab);

@property (nonatomic, readonly) CGRect cancelButtonFrame;

- (instancetype)initWithBackButtonTitle:(NSString *)backButtonTitle doneButtonTitle:(NSString *)doneButtonTitle accentedDone:(bool)accentedDone solidBackground:(bool)solidBackground;

- (void)transitionInAnimated:(bool)animated;
- (void)transitionInAnimated:(bool)animated transparent:(bool)transparent;
- (void)transitionOutAnimated:(bool)animated;
- (void)transitionOutAnimated:(bool)animated transparent:(bool)transparent hideOnCompletion:(bool)hideOnCompletion;

- (void)setDoneButtonEnabled:(bool)enabled animated:(bool)animated;
- (void)setEditButtonsEnabled:(bool)enabled animated:(bool)animated;
- (void)setEditButtonsHidden:(bool)hidden animated:(bool)animated;
- (void)setEditButtonsHighlighted:(TGPhotoEditorTab)buttons;

@property (nonatomic, readonly) TGPhotoEditorTab currentTabs;
- (void)setToolbarTabs:(TGPhotoEditorTab)tabs animated:(bool)animated;

- (void)setActiveTab:(TGPhotoEditorTab)tab;

- (void)calculateLandscapeSizeForPossibleButtonTitles:(NSArray *)possibleButtonTitles;
- (CGFloat)landscapeSize;

@end
