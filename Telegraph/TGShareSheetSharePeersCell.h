#import <UIKit/UIKit.h>

@class TGConversation;

@interface TGShareSheetSharePeersCell : UICollectionViewCell

@property (nonatomic, copy) void (^toggleSelected)(int64_t peerId);
@property (nonatomic, copy) void (^longTap)(int64_t peerId);

- (void)setPeer:(id)peer;
- (int64_t)peerId;
- (void)updateSelectedPeerIds:(NSSet *)selectedPeerIds animated:(bool)animated;

- (void)setUnreadCount:(int32_t)unreadCount;

@end
