#import <UIKit/UIKit.h>

#import "TGOverlayControllerWindow.h"
#import "TGStickerPackPreviewView.h"

#import "TGStickerPack.h"

@interface TGStickerPackPreviewWindow : TGOverlayControllerWindow

@property (nonatomic, strong, readonly) TGStickerPackPreviewView *view;

- (instancetype)initWithParentController:(TGViewController *)parentController stickerPack:(TGStickerPack *)stickerPack;

@end
