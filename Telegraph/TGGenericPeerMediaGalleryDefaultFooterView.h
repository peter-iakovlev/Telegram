#import <LegacyComponents/TGModernGalleryDefaultFooterView.h>

@class TGViewController;
@class TGGenericPeerGalleryGroupItem;

@interface TGGenericPeerMediaGalleryDefaultFooterView : UIView <TGModernGalleryDefaultFooterView>

@property (nonatomic, weak) TGViewController *parentController;
@property (nonatomic, copy) void (^openLinkRequested)(NSString *);
@property (nonatomic, copy) void (^groupItemChanged)(TGGenericPeerGalleryGroupItem *, bool);
- (void)setGroupItems:(NSArray *)groupItems;

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset;

@end
