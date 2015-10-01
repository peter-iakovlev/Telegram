#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;

@interface TGStickerCollectionViewCell : UICollectionViewCell

- (void)setDocumentMedia:(TGDocumentMediaAttachment *)documentMedia;

- (void)setDisabledTimeout;
- (bool)isEnabled;
- (void)setHighlightedWithBounce:(bool)highlighted;

@end
