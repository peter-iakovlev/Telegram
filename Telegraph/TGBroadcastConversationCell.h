#import <UIKit/UIKit.h>

@interface TGBroadcastConversationCell : UITableViewCell

- (void)setConversationId:(int64_t)conversationId;
- (void)setTitle:(NSString *)title;
- (void)setStatus:(NSString *)status;

@end
