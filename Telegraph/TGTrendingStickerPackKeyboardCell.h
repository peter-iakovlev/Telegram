#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;
@class TGStickerPack;

@interface TGTrendingStickerPackKeyboardCell : UICollectionViewCell

@property (nonatomic, copy) void (^install)();
@property (nonatomic, copy) void (^info)();

@property (nonatomic, strong) TGStickerPack *stickerPack;
@property (nonatomic) bool installed;
@property (nonatomic) bool unread;

@end
