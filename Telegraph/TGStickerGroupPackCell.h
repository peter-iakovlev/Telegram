#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGStickerGroupPackCell : UICollectionViewCell

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic, copy) void (^pressed)(void);

@end
