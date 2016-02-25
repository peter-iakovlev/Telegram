#import "TGViewController.h"
#import "TGNotificationContentView.h"

@interface TGNotificationController : TGViewController

@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, copy) void (^navigateToConversation)(int64_t conversationId);

- (void)displayNotificationForConversation:(TGConversation *)conversation identifier:(int32_t)identifier replyToMid:(int32_t)replyToMid duration:(NSTimeInterval)duration configure:(void (^)(TGNotificationContentView *view, bool *isRepliable))configure;
- (void)dismissNotificationsForConversationId:(int64_t)conversationId;
- (void)dismissAllNotifications;

- (bool)shouldDisplayNotificationForConversation:(TGConversation *)conversation;

- (void)expandCurrentNotification;

- (void)localizationUpdated;

@end
