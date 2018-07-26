#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;
@class TGStickerPack;

@class TGStickerCollectionViewCell;

@class TGPresentation;

@interface TGTrendingStickerPackKeyboardCell : UICollectionViewCell

@property (nonatomic, copy) void (^install)();
@property (nonatomic, copy) void (^info)();

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic, strong) TGStickerPack *stickerPack;
@property (nonatomic) bool installed;
@property (nonatomic) bool unread;

- (void)enumerateCells:(void (^)(TGStickerCollectionViewCell *))enumerationBlock;
- (TGStickerCollectionViewCell *)cellForDocument:(TGDocumentMediaAttachment *)document;

- (void)clearHighlight;

@end
