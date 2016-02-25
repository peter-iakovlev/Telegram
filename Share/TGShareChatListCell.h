#import <UIKit/UIKit.h>

@class TGChatModel;
@class TGShareContext;

@interface TGShareChatListCell : UITableViewCell

- (void)setChatModel:(TGChatModel *)chatModel associatedUsers:(NSArray *)associatedUsers shareContext:(TGShareContext *)shareContext;

- (void)setSelectionEnabled:(bool)enabled animated:(bool)animated;
- (void)setChecked:(bool)checked animated:(bool)animated;

@end
