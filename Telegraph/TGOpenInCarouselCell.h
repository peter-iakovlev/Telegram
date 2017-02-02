#import <UIKit/UIKit.h>

@class TGOpenInAppItem;

@interface TGOpenInCarouselCell : UICollectionViewCell

- (void)setAppItem:(TGOpenInAppItem *)appItem;

@end

extern NSString *const TGOpenInCarouselCellIdentifier;
