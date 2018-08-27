#import <UIKit/UIKit.h>

@class TGPresentation;
@class TGNotificationException;

@interface TGNotificationExceptionCell : UITableViewCell

@property (nonatomic, copy) void (^deletePressed)(void);

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic) bool isLastCell;

- (void)setException:(TGNotificationException *)exception peers:(NSDictionary *)peers;

- (bool)isEditingControlsExpanded;
- (void)setEditingConrolsExpanded:(bool)expanded animated:(bool)animated;

@end
