#import <UIKit/UIKit.h>

#import <LegacyComponents/TGStickerPack.h>

@class TGViewController;

@interface TGStickerPackPreviewView : UIView

@property (nonatomic, weak) TGViewController *controller;
@property (nonatomic, copy) void (^dismiss)();

- (void)animateAppear;
- (void)animateDismiss:(void (^)())completion;

- (void)setStickerPack:(TGStickerPack *)stickerPack;
- (void)setAction:(void (^)())action title:(NSString *)title;

@end
