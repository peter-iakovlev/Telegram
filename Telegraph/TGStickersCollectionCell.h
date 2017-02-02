#import <UIKit/UIKit.h>

@class TGDocumentMediaAttachment;

@interface TGStickersCollectionCell : UICollectionViewCell

@property (nonatomic, readonly) TGDocumentMediaAttachment *sticker;

- (void)setSticker:(TGDocumentMediaAttachment *)documentMedia associations:(NSArray *)associations mask:(bool)mask;
- (void)setHighlighted:(bool)highlighted animated:(bool)animated;

- (void)performTransitionIn;

- (void)setAltTick:(NSInteger)tick;

@end

extern NSString *const TGStickersCollectionCellIdentifier;
