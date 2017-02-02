#import "TGStickerKeyboardView.h"

@interface TGStickerKeyboardTabPanel : UIView

@property (nonatomic, copy) void (^currentStickerPackIndexChanged)(NSUInteger);
@property (nonatomic, copy) void (^navigateToGifs)();
@property (nonatomic, copy) void (^navigateToTrendingFirst)();
@property (nonatomic, copy) void (^navigateToTrendingLast)();

- (instancetype)initWithFrame:(CGRect)frame style:(TGStickerKeyboardViewStyle)style;

- (void)setStickerPacks:(NSArray *)stickerPacks showRecent:(bool)showRecent showGifs:(bool)showGifs showTrendingFirst:(bool)showTrendingFirst showTrendingLast:(bool)showTrendingLast;
- (void)setCurrentStickerPackIndex:(NSUInteger)currentStickerPackIndex animated:(bool)animated;
- (void)setCurrentGifsModeSelected;
- (void)setCurrentTrendingModeSelected;
- (void)setTrendingStickersBadge:(NSString *)badge;

@end
