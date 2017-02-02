#import "TGOverlayController.h"

@class TGSuggestionContext;
@class TGVideoEditAdjustments;

@interface TGFastCameraController : TGOverlayController

@property (nonatomic, copy) void(^finishedWithPhoto)(UIImage *resultImage, NSString *caption, NSArray *stickers);
@property (nonatomic, copy) void(^finishedWithVideo)(NSURL *videoURL, UIImage *previewImage, NSTimeInterval duration, CGSize dimensions, TGVideoEditAdjustments *adjustments, NSString *caption, NSArray *stickers);

@property (nonatomic, assign) bool shouldStoreCapturedAssets;
@property (nonatomic, assign) bool allowCaptions;
@property (nonatomic, assign) bool inhibitDocumentCaptions;
@property (nonatomic, strong) TGSuggestionContext *suggestionContext;

- (instancetype)initWithParentController:(TGViewController *)parentController attachmentButtonFrame:(CGRect)attachmentButtonFrame;

- (void)handlePanAt:(CGPoint)location;
- (void)handleReleaseAt:(CGPoint)location;

@end
