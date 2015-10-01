#import <UIKit/UIKit.h>

@class TGChatModel;
@class TGShareContext;

@interface TGShareChatListCell : UITableViewCell

- (void)setChatModel:(TGChatModel *)chatModel associatedUsers:(NSArray *)associatedUsers shareContext:(TGShareContext *)shareContext;

@end
