#import <UIKit/UIKit.h>

@class TGBotComandInfo;
@class TGUser;
@class TGConversationAssociatedInputPanelPallete;

@interface TGCommandPanelCell : UITableViewCell

@property (nonatomic, strong) TGConversationAssociatedInputPanelPallete *pallete;
@property (nonatomic, copy) void (^substituteCommand)(TGBotComandInfo *commandInfo);

- (void)setCommandInfo:(TGBotComandInfo *)commandInfo user:(TGUser *)user;

@end
