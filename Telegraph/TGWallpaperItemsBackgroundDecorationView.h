#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGWallpaperItemsBackgroundDecorationAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, strong) TGPresentation *presentation;

@end

@interface TGWallpaperItemsBackgroundDecorationView : UICollectionReusableView

+ (NSString *)kind;

@end
