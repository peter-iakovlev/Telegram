#import <UIKit/UIKit.h>

@class PGCamera;
@class TGCameraPreviewView;

@interface TGAttachmentSheetRecentCameraView : UIView

@property (nonatomic, copy) void (^pressed)(void);

- (instancetype)initWithFrontCamera:(bool)withFrontCamera;

@property (nonatomic, readonly) bool previewViewAttached;
- (void)detachPreviewView;
- (void)attachPreviewViewAnimated:(bool)animated;

- (void)startPreview;
- (void)stopPreview;
- (void)resumePreview;
- (void)pausePreview;

- (TGCameraPreviewView *)previewView;

@end
