#import "TGStickerKeyboardView.h"

@class TGDocumentMediaAttachment;

@interface TGStickerKeyboardTabCell : UICollectionViewCell

- (void)setRecent;
- (void)setNone;
- (void)setDocumentMedia:(TGDocumentMediaAttachment *)documentMedia;

- (void)setStyle:(TGStickerKeyboardViewStyle)style;

- (void)setInnerAlpha:(CGFloat)innerAlpha;

@end
