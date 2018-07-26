#import <UIKit/UIKit.h>

@class TGDialogListRecentPeers;
@class TGPresentation;

@interface TGDialogListRecentPeersCell : UITableViewCell

@property (nonatomic, copy) void (^toggleExpand)();
@property (nonatomic, copy) void (^peerSelected)(id);
@property (nonatomic, copy) void (^peerLongTap)(id);

@property (nonatomic) bool expanded;
@property (nonatomic, assign) UIEdgeInsets safeAreaInset;
@property (nonatomic, strong) TGPresentation *presentation;

+ (CGFloat)heightForWidth:(CGFloat)width count:(NSInteger)count expanded:(bool)expanded;

- (void)setRecentPeers:(TGDialogListRecentPeers *)recentPeers unreadCounts:(NSDictionary *)unreadCounts;
- (void)updateUnreadCounts:(NSDictionary *)unreadCounts;
- (void)updateSelectedPeerIds:(NSArray *)peerIds;

- (int64_t)peerAtPoint:(CGPoint)point frame:(CGRect *)frame;

@end
