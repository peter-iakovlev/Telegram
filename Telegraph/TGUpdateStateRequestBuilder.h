/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "ASActor.h"

#import "ActionStage.h"

#import "TL/TLMetaScheme.h"

@interface TGUpdateStateRequestBuilder : ASActor <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

+ (void)scheduleInitialUpdates;

+ (void)clearStateHistory;
+ (int)stateVersion;

+ (void)applyDelayedOutgoingMessages:(int64_t)conversationId;

+ (void)addIgnoreConversationId:(int64_t)conversationId;
+ (bool)ignoringConversationId:(int64_t)conversationId;
+ (void)removeIgnoreConversationId:(int64_t)conversationId;

+ (bool)applyUpdates:(NSArray *)addedMessagesDesc addedParsedMessages:(NSArray *)addedParsedMessages otherUpdates:(NSArray *)otherUpdates addedEncryptedActions:(NSArray *)addedEncryptedActions usersDesc:(NSArray *)usersDesc chatsDesc:(NSArray *)chatsDesc chatParticipantsDesc:(NSArray *)chatParticipantsDesc updatesWithDates:(NSArray *)updatesWithDates;
+ (void)processDelayedMessagesInConversation:(int64_t)conversationId completedPath:(NSString *)path;

- (void)stateDeltaRequestSuccess:(TLupdates_Difference *)difference;
- (void)stateDeltaRequestFailed;

- (void)stateRequestSuccess:(TLupdates_State *)state;
- (void)stateRequestFailed;

@end
