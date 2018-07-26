#import <UIKit/UIKit.h>

@class TGDialogListRecentPeers;
@class TGPresentation;

@interface TGShareCollectionRecentPeersCell : UICollectionViewCell

@property (nonatomic, copy) bool (^isChecked)(int64_t peerId);
@property (nonatomic, copy) bool (^toggleChecked)(int64_t peerId, id peer);

@property (nonatomic, strong) TGPresentation *presentation;

- (void)setRecentPeers:(TGDialogListRecentPeers *)recentPeers;

@end

extern NSString *const TGShareCollectionRecentPeersCellIdentifier;
