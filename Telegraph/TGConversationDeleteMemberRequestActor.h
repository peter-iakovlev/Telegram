/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGActor.h"

#import "tl/TLMetaScheme.h"

#import "TGTelegraphProtocols.h"

@interface TGConversationDeleteMemberRequestActor : TGActor <TGDeleteChatMemberProtocol>

- (void)deleteMemberSuccess:(TLUpdates *)statedMessage;
- (void)deleteMemberFailed;

@end
