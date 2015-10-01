/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGGenericModernConversationCompanion.h"

@class TGUser;

@interface TGPrivateModernConversationCompanion : TGGenericModernConversationCompanion
{
    int32_t _uid;
}

@property (nonatomic, strong) NSString *botStartPayload;

- (instancetype)initWithUid:(int)uid activity:(NSString *)activity mayHaveUnreadMessages:(bool)mayHaveUnreadMessages;
- (instancetype)initWithConversationId:(int64_t)conversationId uid:(int)uid activity:(NSString *)activity mayHaveUnreadMessages:(bool)mayHaveUnreadMessages;

- (void)setAdditionalTitleIcons:(NSArray *)additionalTitleIcons;
- (bool)shouldDisplayContactLinkPanel;

- (void)standaloneSendBotStartPayload:(NSString *)payload;

@end
