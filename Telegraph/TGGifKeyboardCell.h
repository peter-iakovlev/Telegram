#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;

@interface TGGifKeyboardCellContents : UIView

@property (nonatomic, strong) TGDocumentMediaAttachment *document;

@end

@interface TGGifKeyboardCell : UICollectionViewCell

@property (nonatomic) bool enableAnimation;

- (void)setDocument:(TGDocumentMediaAttachment *)document;

- (TGGifKeyboardCellContents *)_takeContents;
- (void)_putContents:(TGGifKeyboardCellContents *)contents;

@end
