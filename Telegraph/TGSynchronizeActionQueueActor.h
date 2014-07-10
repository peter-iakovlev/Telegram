/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGActor.h"

#import "TL/TLMetaScheme.h"

#import "TGTelegraphProtocols.h"

@interface TGSynchronizeActionQueueActor : TGActor <TGDeleteChatMemberProtocol>

- (void)readMessagesSuccess:(TLmessages_AffectedHistory *)affectedHistory;
- (void)readMessagesFailed;

- (void)deleteMessagesSuccess:(NSArray *)deletedMids;
- (void)deleteMessagesFailed;

- (void)deleteHistorySuccess:(TLmessages_AffectedHistory *)affectedHistory;
- (void)deleteHistoryFailed;

- (void)deleteMemberSuccess:(TLmessages_StatedMessage *)statedMessage;
- (void)deleteMemberFailed;

- (void)rejectEncryptedChatSuccess;
- (void)rejectEncryptedChatFailed;

- (void)readEncryptedSuccess;
- (void)readEncryptedFailed;

@end
