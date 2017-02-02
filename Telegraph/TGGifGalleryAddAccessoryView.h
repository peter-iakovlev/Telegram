#import "TGModernGalleryDefaultFooterAccessoryView.h"

@interface TGGifGalleryAddAccessoryView : UIView <TGModernGalleryDefaultFooterAccessoryView>

@property (nonatomic, copy) void (^action)(id<TGModernGalleryItem>, TGGifGalleryAddAccessoryView *);

@end
