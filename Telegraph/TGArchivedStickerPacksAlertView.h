#import <UIKit/UIKit.h>

@class TGViewController;

@interface TGArchivedStickerPacksAlertView : UIView

@property (nonatomic, weak) TGViewController *controller;
@property (nonatomic, copy) void (^dismiss)();

- (void)animateAppear;
- (void)animateDismiss:(void (^)())completion;

- (void)setStickerPacks:(NSArray *)stickerPacks;

@end
