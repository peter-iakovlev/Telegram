/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPrivateModernConversationCompanion.h"

@interface TGSecretModernConversationCompanion : TGPrivateModernConversationCompanion

- (instancetype)initWithEncryptedConversationId:(int64_t)encryptedConversationId accessHash:(int64_t)accessHash conversationId:(int64_t)conversationId uid:(int)uid activity:(NSString *)activity mayHaveUnreadMessages:(bool)mayHaveUnreadMessages;

@end
