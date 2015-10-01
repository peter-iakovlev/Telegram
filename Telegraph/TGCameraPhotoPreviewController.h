#import "TGOverlayController.h"

@class SSignal;
@class PGCameraShotMetadata;
@class PGPhotoEditorValues;

@interface TGCameraPhotoPreviewController : TGOverlayController

@property (nonatomic, assign) bool disallowCaptions;

@property (nonatomic, copy) CGRect(^beginTransitionIn)(void);
@property (nonatomic, copy) CGRect(^beginTransitionOut)(CGRect referenceFrame);

@property (nonatomic, copy) void (^photoEditorShown)(void);
@property (nonatomic, copy) void (^photoEditorHidden)(void);

@property (nonatomic, copy) void(^retakePressed)(void);
@property (nonatomic, copy) void(^sendPressed)(UIImage *originalImage, UIImage *resultImage, PGPhotoEditorValues *editorValues, NSString *caption);

@property (nonatomic, copy) SSignal *(^userListSignal)(NSString *mention);
@property (nonatomic, copy) SSignal *(^hashtagListSignal)(NSString *hashtag);

- (instancetype)initWithImage:(UIImage *)image metadata:(PGCameraShotMetadata *)metadata;

@end
