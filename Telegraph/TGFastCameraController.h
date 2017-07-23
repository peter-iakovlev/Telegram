#import "TGOverlayController.h"

@class TGSuggestionContext;
@class TGVideoEditAdjustments;

@interface TGFastCameraController : TGOverlayController

@property (nonatomic, copy) void(^finishedWithPhoto)(UIImage *resultImage, NSString *caption, NSArray *stickers, NSNumber *timer);
@property (nonatomic, copy) void(^finishedWithVideo)(NSURL *videoURL, UIImage *previewImage, NSTimeInterval duration, CGSize dimensions, TGVideoEditAdjustments *adjustments, NSString *caption, NSArray *stickers, NSNumber *timer);

@property (nonatomic, assign) bool shouldStoreCapturedAssets;
@property (nonatomic, assign) bool allowCaptions;
@property (nonatomic, assign) bool inhibitDocumentCaptions;
@property (nonatomic, assign) bool hasTimer;
@property (nonatomic, strong) TGSuggestionContext *suggestionContext;

@property (nonatomic, strong) NSString *recipientName;

- (instancetype)initWithParentController:(TGViewController *)parentController attachmentButtonFrame:(CGRect)attachmentButtonFrame;

- (void)handlePanAt:(CGPoint)location;
- (void)handleReleaseAt:(CGPoint)location;

@end
