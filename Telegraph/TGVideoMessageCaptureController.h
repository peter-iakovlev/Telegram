#import "TGOverlayController.h"

@class TGLiveUploadActorData;
@class TGVideoEditAdjustments;

@interface TGVideoMessageCaptureController : TGOverlayController

@property (nonatomic, copy) id (^requestActivityHolder)();
@property (nonatomic, copy) void (^micLevel)(CGFloat level);
@property (nonatomic, copy) void(^finishedWithVideo)(NSURL *videoURL, UIImage *previewImage, NSUInteger fileSize, NSTimeInterval duration, CGSize dimensions, TGLiveUploadActorData *liveUploadData, TGVideoEditAdjustments *adjustments);
@property (nonatomic, copy) void(^onDismiss)(bool isAuto);
@property (nonatomic, copy) void(^onStop)(void);
@property (nonatomic, copy) void(^onCancel)(void);

- (instancetype)initWithParentController:(TGViewController *)parentController controlsFrame:(CGRect)controlsFrame isAlreadyLocked:(bool (^)(void))isAlreadyLocked;
- (void)buttonInteractionUpdate:(CGPoint)value;
- (void)setLocked;

- (void)complete;
- (void)dismiss;
- (void)stop;

+ (void)clearStartImage;

+ (void)requestCameraAccess:(void (^)(bool granted, bool wasNotDetermined))resultBlock;
+ (void)requestMicrophoneAccess:(void (^)(bool granted, bool wasNotDetermined))resultBlock;

@end
