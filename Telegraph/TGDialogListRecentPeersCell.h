#import <UIKit/UIKit.h>

@class TGDialogListRecentPeers;

@interface TGDialogListRecentPeersCell : UITableViewCell

@property (nonatomic, copy) void (^toggleExpand)();
@property (nonatomic, copy) void (^peerSelected)(id);
@property (nonatomic, copy) void (^peerLongTap)(id);

@property (nonatomic) bool expanded;

+ (CGFloat)heightForWidth:(CGFloat)width count:(NSInteger)count expanded:(bool)expanded;

- (void)setRecentPeers:(TGDialogListRecentPeers *)recentPeers unreadCounts:(NSDictionary *)unreadCounts;
- (void)updateUnreadCounts:(NSDictionary *)unreadCounts;
- (void)updateSelectedPeerIds:(NSArray *)peerIds;

- (int64_t)peerAtPoint:(CGPoint)point frame:(CGRect *)frame;

@end
