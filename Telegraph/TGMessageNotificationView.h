/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGMessage.h"
#import "TGUser.h"

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
