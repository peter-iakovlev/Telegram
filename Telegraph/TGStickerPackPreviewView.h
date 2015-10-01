#import <UIKit/UIKit.h>

#import "TGStickerPack.h"

@interface TGStickerPackPreviewView : UIView

@property (nonatomic, copy) void (^dismiss)();

- (void)animateAppear;
- (void)animateDismiss:(void (^)())completion;

- (void)setStickerPack:(TGStickerPack *)stickerPack;
- (void)setAction:(void (^)())action title:(NSString *)title;

@end
