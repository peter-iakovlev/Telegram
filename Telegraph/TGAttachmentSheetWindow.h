#import "TGAttachmentSheetView.h"

@interface TGAttachmentSheetWindow : UIWindow

@property (nonatomic, copy) void(^dismissalBlock)(void);

- (void)switchToSheetView:(TGAttachmentSheetView *)sheetView;
- (void)switchToSheetView:(TGAttachmentSheetView *)sheetView stickToBottom:(bool)stickToBottom;

- (void)showAnimated:(bool)animated completion:(void (^)(void))completion;
- (void)dismissAnimated:(bool)animated completion:(void (^)(void))completion;

- (TGAttachmentSheetView *)view;

@end
