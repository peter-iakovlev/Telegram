/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGFutureAction.h"

#define TGSynchronizeEncryptedChatSettingsFutureActionType ((int)0xba127321)

@interface TGSynchronizeEncryptedChatSettingsFutureAction : TGFutureAction

@property (nonatomic) int messageLifetime;
@property (nonatomic) int64_t messageRandomId;

- (id)initWithEncryptedConversationId:(int64_t)encryptedConversationId messageLifetime:(int)messageLifetime messageRandomId:(int64_t)messageRandomId;

@end
