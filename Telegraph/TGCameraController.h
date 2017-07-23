#import "TGOverlayController.h"
#import "TGOverlayControllerWindow.h"

@class PGCamera;
@class TGCameraPreviewView;
@class TGSuggestionContext;
@class TGVideoEditAdjustments;

typedef enum {
    TGCameraControllerGenericIntent,
    TGCameraControllerAvatarIntent,
} TGCameraControllerIntent;

@interface TGCameraControllerWindow : TGOverlayControllerWindow

@end

@interface TGCameraController : TGOverlayController

@property (nonatomic, assign) bool liveUploadEnabled;
@property (nonatomic, assign) bool shouldStoreCapturedAssets;

@property (nonatomic, assign) bool allowCaptions;
@property (nonatomic, assign) bool inhibitDocumentCaptions;
@property (nonatomic, assign) bool hasTimer;
@property (nonatomic, strong) TGSuggestionContext *suggestionContext;

@property (nonatomic, strong) NSString *recipientName;

@property (nonatomic, copy) void(^finishedWithPhoto)(TGOverlayController *controller, UIImage *resultImage, NSString *caption, NSArray *stickers, NSNumber *timer);
@property (nonatomic, copy) void(^finishedWithVideo)(TGOverlayController *controller, NSURL *videoURL, UIImage *previewImage, NSTimeInterval duration, CGSize dimensions, TGVideoEditAdjustments *adjustments, NSString *caption, NSArray *stickers, NSNumber *timer);

@property (nonatomic, copy) CGRect(^beginTransitionOut)(void);
@property (nonatomic, copy) void(^finishedTransitionOut)(void);

- (instancetype)initWithIntent:(TGCameraControllerIntent)intent;
- (instancetype)initWithCamera:(PGCamera *)camera previewView:(TGCameraPreviewView *)previewView intent:(TGCameraControllerIntent)intent;

- (void)beginTransitionInFromRect:(CGRect)rect;

+ (UIInterfaceOrientation)_interfaceOrientationForDeviceOrientation:(UIDeviceOrientation)orientation;

+ (void)startShortcutCamera;

+ (bool)useLegacyCamera;

@end
