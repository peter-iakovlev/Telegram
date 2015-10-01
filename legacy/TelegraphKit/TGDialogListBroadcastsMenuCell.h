#import <UIKit/UIKit.h>

@interface TGDialogListBroadcastsMenuCell : UITableViewCell

@property (nonatomic, copy) void (^broadcastListsPressed)();
@property (nonatomic, copy) void (^newGroupPressed)();

- (void)resetLocalization;

@end
