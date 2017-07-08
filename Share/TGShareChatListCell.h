#import <UIKit/UIKit.h>

@class TGChatModel;
@class TGShareContext;

@interface TGShareChatListCell : UITableViewCell

- (void)setChatModel:(TGChatModel *)chatModel associatedUsers:(id)associatedUsers shareContext:(TGShareContext *)shareContext;
- (void)setChecked:(bool)checked animated:(bool)animated;

@end
