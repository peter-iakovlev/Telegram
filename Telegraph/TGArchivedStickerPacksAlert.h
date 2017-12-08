#import <LegacyComponents/LegacyComponents.h>

#import "TGArchivedStickerPacksAlertView.h"

@interface TGArchivedStickerPacksAlert : TGOverlayControllerWindow

@property (nonatomic, strong, readonly) TGArchivedStickerPacksAlertView *view;

- (instancetype)initWithManager:(id<LegacyComponentsOverlayWindowManager>)manager parentController:(TGViewController *)parentController stickerPacks:(NSArray *)stickerPacks;

@end
