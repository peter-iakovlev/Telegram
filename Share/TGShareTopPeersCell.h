#import <UIKit/UIKit.h>

@class TGShareContext;

@interface TGShareTopPeersCell : UITableViewCell

@property (nonatomic, copy) bool (^isChecked)(int64_t peerId);
@property (nonatomic, copy) void (^checked)(int64_t peerId);

@property (nonatomic, assign) UIEdgeInsets safeAreaInset;

- (void)setPeers:(NSArray *)peers shareContext:(TGShareContext *)shareContext;

@end
