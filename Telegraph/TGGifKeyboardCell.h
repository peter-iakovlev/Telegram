#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;

@interface TGGifKeyboardCellContents : UIView

@property (nonatomic, strong) TGDocumentMediaAttachment *document;

@end

@interface TGGifKeyboardCell : UICollectionViewCell

@property (nonatomic, readonly) TGGifKeyboardCellContents *contents;
@property (nonatomic) bool enableAnimation;

- (void)setDocument:(TGDocumentMediaAttachment *)document;

- (TGGifKeyboardCellContents *)_takeContents;
- (void)_putContents:(TGGifKeyboardCellContents *)contents;

- (void)setHighlighted:(bool)highlighted animated:(bool)__unused animated;

@end
