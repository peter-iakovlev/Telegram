#import <UIKit/UIKit.h>

@class TGStickerPack;

@interface TGMultipleStickerPacksCell : UICollectionViewCell

@property (nonatomic) bool installed;

@property (nonatomic, copy) void (^install)();
@property (nonatomic, strong) TGStickerPack *stickerPack;

@end
