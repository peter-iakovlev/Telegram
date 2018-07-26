#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGShareTargetCell : UITableViewCell

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, strong) TGPresentation *presentation;

- (void)setupWithPeer:(id)peer feed:(bool)feed;
- (void)setChecked:(bool)checked animated:(bool)animated;
- (void)setIsLastCell:(bool)lastCell;

@end
