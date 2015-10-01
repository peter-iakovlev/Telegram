#import "TGModernGalleryDefaultFooterAccessoryView.h"

@interface TGGenericPeerMediaGalleryActionsAccessoryView : UIView <TGModernGalleryDefaultFooterAccessoryView>

@property (nonatomic, copy) void (^action)(id<TGModernGalleryItem>);

@end
