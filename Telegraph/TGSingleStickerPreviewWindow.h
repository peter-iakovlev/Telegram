#import "TGOverlayControllerWindow.h"
#import "TGSingleStickerPreviewView.h"

@interface TGSingleStickerPreviewWindow : TGOverlayControllerWindow

@property (nonatomic, strong, readonly) TGSingleStickerPreviewView *view;

- (instancetype)initWithParentController:(TGViewController *)parentController;

@end
