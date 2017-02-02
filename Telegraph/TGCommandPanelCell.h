#import <UIKit/UIKit.h>

@class TGBotComandInfo;
@class TGUser;

@interface TGCommandPanelCell : UITableViewCell

@property (nonatomic, copy) void (^substituteCommand)(TGBotComandInfo *commandInfo);

- (void)setCommandInfo:(TGBotComandInfo *)commandInfo user:(TGUser *)user;

@end
