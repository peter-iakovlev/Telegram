#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;

@interface TGStickerAssociatedInputPanelCell : UICollectionViewCell

@property (nonatomic, strong) TGDocumentMediaAttachment *document;

- (void)setHighlighted:(bool)highlighted animated:(bool)animated;

@end
