#import <UIKit/UIKit.h>

@class TGMessage;
@class TGUser;

@interface TGCallCell : UITableViewCell

@property (nonatomic, copy) void (^infoPressed)(void);

@property (nonatomic) bool isLastCell;

- (void)setupWithMessage:(TGMessage *)message peer:(TGUser *)peer;

@end
