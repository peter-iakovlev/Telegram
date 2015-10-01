#import "TGAttachmentSheetItemView.h"

@class SSignal;
@class TGViewController;
@class TGAttachmentSheetRecentControlledButtonItemView;
@class TGAttachmentSheetRecentCameraView;

typedef enum {
    TGAttachmentSheetItemViewSendPhotoMode,
    TGAttachmentSheetItemViewSetProfilePhotoMode,
    TGAttachmentSheetItemViewSetGroupPhotoMode
} TGAttachmentSheetItemViewMode;

@interface TGAttachmentSheetRecentItemView : TGAttachmentSheetItemView

@property (nonatomic, copy) void (^openCamera)(TGAttachmentSheetRecentCameraView *);
@property (nonatomic, copy) void (^itemOpened)();
@property (nonatomic, copy) void (^avatarCreated)(UIImage *resultImage);
@property (nonatomic, copy) void (^done)();

@property (nonatomic, copy) SSignal *(^userListSignal)(NSString *mention);
@property (nonatomic, copy) SSignal *(^hashtagListSignal)(NSString *hashtag);

@property (nonatomic, assign) bool disallowCaptions;

- (instancetype)initWithParentController:(TGViewController *)controller mode:(TGAttachmentSheetItemViewMode)mode;

- (void)setMultifunctionButtonView:(TGAttachmentSheetRecentControlledButtonItemView *)multifunctionButtonView;
- (NSArray *)selectedItemSignals:(id (^)(UIImage *, NSString *, NSString *))imageDescriptionGenerator;

@end
