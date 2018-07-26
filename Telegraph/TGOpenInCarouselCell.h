#import <UIKit/UIKit.h>

@class TGOpenInAppItem;
@class TGMenuSheetPallete;

@interface TGOpenInCarouselCell : UICollectionViewCell

@property (nonatomic, strong) TGMenuSheetPallete *pallete;
- (void)setAppItem:(TGOpenInAppItem *)appItem;
- (void)setCornersImage:(UIImage *)cornersImage;

@end

extern NSString *const TGOpenInCarouselCellIdentifier;
