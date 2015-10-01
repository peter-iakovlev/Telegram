#import "TGModernGalleryDefaultFooterAccessoryView.h"

@interface TGGenericPeerMediaGalleryDeleteAccessoryView : UIView <TGModernGalleryDefaultFooterAccessoryView>

@property (nonatomic, copy) void (^action)(id<TGModernGalleryItem>);

@end
