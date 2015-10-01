#import <UIKit/UIKit.h>

@interface TGStickerKeyboardTabPanel : UIView

@property (nonatomic, copy) void (^currentStickerPackIndexChanged)(NSUInteger);

- (void)setStickerPacks:(NSArray *)stickerPacks showRecent:(bool)showRecent;
- (void)setCurrentStickerPackIndex:(NSUInteger)currentStickerPackIndex;

@end
