#import <LegacyComponents/TGModernGalleryDefaultFooterView.h>

@class TGGenericPeerGalleryGroupItem;

@interface TGGenericPeerMediaGalleryDefaultFooterView : UIView <TGModernGalleryDefaultFooterView>

@property (nonatomic, copy) void (^groupItemChanged)(TGGenericPeerGalleryGroupItem *, bool);
- (void)setGroupItems:(NSArray *)groupItems;

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset;

@end
