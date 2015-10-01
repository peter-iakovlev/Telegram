#import "TGOverlayController.h"

#import "TGEditablePhotoItem.h"
#import "TGEditablePhotoItem.h"

#import "TGPhotoToolbarView.h"

@class SSignal;
@class PGPhotoEditorValues;
@class PGCameraShotMetadata;
@class TGPhotoEditorController;

typedef enum {
    TGPhotoEditorControllerGenericIntent = 0,
    TGPhotoEditorControllerAvatarIntent = 1,
    TGPhotoEditorControllerFromCameraIntent = (1 << 1),
    TGPhotoEditorControllerWebIntent = (1 << 2),
    TGPhotoEditorControllerVideoIntent = (1 << 3)
} TGPhotoEditorControllerIntent;

@interface TGPhotoEditorController : TGOverlayController

@property (nonatomic, copy) UIView *(^beginTransitionIn)(CGRect *referenceFrame, UIView **parentView);
@property (nonatomic, copy) void (^finishedTransitionIn)(void);
@property (nonatomic, copy) UIView *(^beginTransitionOut)(CGRect *referenceFrame, UIView **parentView);
@property (nonatomic, copy) void (^finishedTransitionOut)(bool saved);

@property (nonatomic, copy) UIImage *(^requestImage)(void);
@property (nonatomic, copy) void (^requestToolbarsHidden)(bool hidden, bool animated);

@property (nonatomic, copy) void (^captionSet)(NSString *caption);

@property (nonatomic, copy) void (^finishedEditing)(id<TGMediaEditAdjustments> adjustments, UIImage *resultImage, UIImage *thumbnailImage, bool noChanges);

@property (nonatomic, assign) bool dontHideStatusBar;
@property (nonatomic, strong) PGCameraShotMetadata *metadata;

@property (nonatomic, copy) SSignal *(^userListSignal)(NSString *mention);
@property (nonatomic, copy) SSignal *(^hashtagListSignal)(NSString *hashtag);

- (instancetype)initWithItem:(id<TGEditablePhotoItem>)item
                      intent:(TGPhotoEditorControllerIntent)intent
                 adjustments:(id<TGMediaEditAdjustments>)adjustments
                     caption:(NSString *)caption
                 screenImage:(UIImage *)screenImage
               availableTabs:(NSArray *)availableTabs
                 selectedTab:(TGPhotoEditorTab)selectedTab;

- (void)updateStatusBarAppearanceForDismiss;

+ (NSArray *)defaultTabsForAvatarIntent;

@end
