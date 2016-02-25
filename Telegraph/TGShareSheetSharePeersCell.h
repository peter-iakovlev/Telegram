#import <UIKit/UIKit.h>

@class TGConversation;

@interface TGShareSheetSharePeersCell : UICollectionViewCell

@property (nonatomic, copy) void (^toggleSelected)(int64_t peerId);

- (void)setPeer:(id)peer;
- (void)updateSelectedPeerIds:(NSSet *)selectedPeerIds animated:(bool)animated;

@end
