#import "TGStickerKeyboardView.h"

@interface TGStickerKeyboardTabPanel : UIView

@property (nonatomic, copy) void (^currentStickerPackIndexChanged)(NSUInteger);
@property (nonatomic, copy) void (^navigateToGifs)();

- (instancetype)initWithFrame:(CGRect)frame style:(TGStickerKeyboardViewStyle)style;

- (void)setStickerPacks:(NSArray *)stickerPacks showRecent:(bool)showRecent showGifs:(bool)showGifs;
- (void)setCurrentStickerPackIndex:(NSUInteger)currentStickerPackIndex;
- (void)setCurrentGifsModeSelected;

@end
