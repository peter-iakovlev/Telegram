#import <UIKit/UIKit.h>

#import <LegacyComponents/LegacyComponents.h>

@interface TGMessageNotificationView : UIView

@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, strong) NSArray *messageAttachments;
@property (nonatomic, strong) NSDictionary *users;
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic) int authorUid;
@property (nonatomic) int64_t conversationId;

@property (nonatomic) bool isLocationNotification;

- (void)resetView;

@end
