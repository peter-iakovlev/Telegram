#import <UIKit/UIKit.h>

@class TGBotComandInfo;
@class TGUser;

@interface TGCommandPanelCell : UITableViewCell

- (void)setCommandInfo:(TGBotComandInfo *)commandInfo user:(TGUser *)user;

@end
