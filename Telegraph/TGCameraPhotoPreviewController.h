#import "TGOverlayController.h"

@class PGCameraShotMetadata;
@class PGPhotoEditorValues;
@class TGSuggestionContext;

@interface TGCameraPhotoPreviewController : TGOverlayController

@property (nonatomic, assign) bool allowCaptions;

@property (nonatomic, copy) CGRect(^beginTransitionIn)(void);
@property (nonatomic, copy) CGRect(^beginTransitionOut)(CGRect referenceFrame);

@property (nonatomic, copy) void(^finishedTransitionIn)(void);

@property (nonatomic, copy) void (^photoEditorShown)(void);
@property (nonatomic, copy) void (^photoEditorHidden)(void);

@property (nonatomic, copy) void(^retakePressed)(void);
@property (nonatomic, copy) void(^sendPressed)(TGOverlayController *controller, UIImage *resultImage, NSString *caption, NSArray *stickers, NSNumber *timer);

@property (nonatomic, strong) TGSuggestionContext *suggestionContext;
@property (nonatomic, assign) bool shouldStoreAssets;
@property (nonatomic, assign) bool hasTimer;

- (instancetype)initWithImage:(UIImage *)image metadata:(PGCameraShotMetadata *)metadata recipientName:(NSString *)recipientName;
- (instancetype)initWithImage:(UIImage *)image metadata:(PGCameraShotMetadata *)metadata recipientName:(NSString *)recipientName backButtonTitle:(NSString *)backButtonTitle doneButtonTitle:(NSString *)doneButtonTitle;


@end
