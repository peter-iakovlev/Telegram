#import "TGOverlayControllerWindow.h"

#import "TGArchivedStickerPacksAlertView.h"

@interface TGArchivedStickerPacksAlert : TGOverlayControllerWindow

@property (nonatomic, strong, readonly) TGArchivedStickerPacksAlertView *view;

- (instancetype)initWithParentController:(TGViewController *)parentController stickerPacks:(NSArray *)stickerPacks;

@end
