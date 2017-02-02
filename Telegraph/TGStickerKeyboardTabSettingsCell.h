#import <UIKit/UIKit.h>

typedef enum {
    TGStickerKeyboardTabSettingsCellSettings,
    TGStickerKeyboardTabSettingsCellGifs,
    TGStickerKeyboardTabSettingsCellTrending
} TGStickerKeyboardTabSettingsCellMode;

@interface TGStickerKeyboardTabSettingsCell : UICollectionViewCell

@property (nonatomic, copy) void (^pressed)();

@property (nonatomic) TGStickerKeyboardTabSettingsCellMode mode;

- (void)setBadge:(NSString *)badge;

@end
