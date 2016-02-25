#import "TGShareSheetView.h"

@interface TGShareSheetWindow : UIWindow

@property (nonatomic, copy) void(^dismissalBlock)(void);

- (void)switchToSheetView:(TGShareSheetView *)sheetView;
- (void)switchToSheetView:(TGShareSheetView *)sheetView stickToBottom:(bool)stickToBottom;

- (void)showAnimated:(bool)animated completion:(void (^)(void))completion;
- (void)dismissAnimated:(bool)animated completion:(void (^)(void))completion;

- (TGShareSheetView *)view;

@end
