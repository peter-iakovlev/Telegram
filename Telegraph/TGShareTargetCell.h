#import <UIKit/UIKit.h>

@interface TGShareTargetCell : UITableViewCell

@property (nonatomic, readonly) int64_t peerId;

- (void)setupWithPeer:(id)peer;
- (void)setChecked:(bool)checked animated:(bool)animated;

@end
