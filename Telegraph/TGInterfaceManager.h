/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "ActionStage.h"

@class TGMessage;
@class TGConversation;
@class TGModernConversationController;

@interface TGInterfaceManager : NSObject <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

+ (TGInterfaceManager *)instance;

- (void)preload;

- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)conversation;
- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)conversation animated:(bool)animated;
- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)conversation performActions:(NSDictionary *)performActions;
- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)conversation performActions:(NSDictionary *)performActions animated:(bool)animated;
- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)conversation performActions:(NSDictionary *)performActions atMessage:(NSDictionary *)atMessage clearStack:(bool)clearStack openKeyboard:(bool)openKeyboard animated:(bool)animated;
- (TGModernConversationController *)configuredConversationControlerWithId:(int64_t)conversationId;

- (TGModernConversationController *)currentControllerWithPeerId:(int64_t)peerId;
- (void)dismissConversation;
- (void)navigateToConversationWithBroadcastUids:(NSArray *)broadcastUids forwardMessages:(NSArray *)forwardMessages;
- (void)navigateToProfileOfUser:(int)uid preferNativeContactId:(int)preferNativeContactId;
- (void)navigateToProfileOfUser:(int)uid;
- (void)navigateToProfileOfUser:(int)uid shareVCard:(void (^)())shareVCard;
- (void)navigateToProfileOfUser:(int)uid encryptedConversationId:(int64_t)encryptedConversationId;
- (void)navigateToMediaListOfConversation:(int64_t)conversationId navigationController:(UINavigationController *)navigationController;

- (void)displayBannerIfNeeded:(TGMessage *)message conversationId:(int64_t)conversationId;
- (void)dismissBannerForConversationId:(int64_t)conversationId;

- (void)displayNearbyBannerIdNeeded:(int)peopleCount;

@end
