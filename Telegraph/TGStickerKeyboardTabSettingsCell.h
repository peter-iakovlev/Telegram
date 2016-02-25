#import <UIKit/UIKit.h>

typedef enum {
    TGStickerKeyboardTabSettingsCellSettings,
    TGStickerKeyboardTabSettingsCellGifs
} TGStickerKeyboardTabSettingsCellMode;

@interface TGStickerKeyboardTabSettingsCell : UICollectionViewCell

@property (nonatomic, copy) void (^pressed)();

- (void)setMode:(TGStickerKeyboardTabSettingsCellMode)mode;

@end
