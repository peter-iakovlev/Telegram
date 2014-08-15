#import "TGModernGalleryDefaultHeaderView.h"

@interface TGGenericPeerMediaGalleryDefaultHeaderView : UIView <TGModernGalleryDefaultHeaderView>

- (instancetype)initWithPositionAndCountBlock:(void (^)(id<TGModernGalleryItem>, NSUInteger *, NSUInteger *))positioAndCountBlock;

@end
