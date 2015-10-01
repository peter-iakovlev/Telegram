#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;

@interface TGStickerKeyboardTabCell : UICollectionViewCell

- (void)setRecent;
- (void)setNone;
- (void)setDocumentMedia:(TGDocumentMediaAttachment *)documentMedia;

@end
