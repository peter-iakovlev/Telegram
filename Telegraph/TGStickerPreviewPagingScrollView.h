#import <UIKit/UIKit.h>

@class TGStickerPack;
@class TGDocumentMediaAttachment;

@interface TGStickerPreviewPagingScrollView : UIScrollView

@property (nonatomic, copy) void (^pageChanged)(CGFloat);

- (void)setStickerPack:(TGStickerPack *)stickerPack;
- (NSUInteger)pageCount;
- (TGDocumentMediaAttachment *)documentAtPoint:(CGPoint)point;

@end
