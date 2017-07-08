#import "TGStickerKeyboardView.h"

typedef enum {
    TGStickerKeyboardTabSettingsCellSettings,
    TGStickerKeyboardTabSettingsCellGifs,
    TGStickerKeyboardTabSettingsCellTrending
} TGStickerKeyboardTabSettingsCellMode;

@interface TGStickerKeyboardTabSettingsCell : UICollectionViewCell

@property (nonatomic, copy) void (^pressed)();

@property (nonatomic) TGStickerKeyboardTabSettingsCellMode mode;

- (void)setBadge:(NSString *)badge;
- (void)setStyle:(TGStickerKeyboardViewStyle)style;

- (void)setInnerAlpha:(CGFloat)innerAlpha;

@end
