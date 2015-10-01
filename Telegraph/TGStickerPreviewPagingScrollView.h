#import <UIKit/UIKit.h>

@class TGStickerPack;

@interface TGStickerPreviewPagingScrollView : UIScrollView

@property (nonatomic, copy) void (^pageChanged)(CGFloat);

- (void)setStickerPack:(TGStickerPack *)stickerPack;
- (NSUInteger)pageCount;

@end
