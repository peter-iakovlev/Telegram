/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGFutureAction.h"

#define TGEncryptedChatServiceActionType ((int)0x68CC189E)

typedef enum {
    TGEncryptedChatServiceActionViewMessage = 1,
    TGEncryptedChatServiceActionChatScreenshotTaken = 2,
    TGEncryptedChatServiceActionMessageScreenshotTaken = 3,
    TGEncryptedChatServiceActionMessagesDeleted = 4
} TGEncryptedChatServiceActions;

@interface TGEncryptedChatServiceAction : TGFutureAction

@property (nonatomic) int64_t encryptedConversationId;
@property (nonatomic) int64_t messageRandomId;
@property (nonatomic) int32_t action;
@property (nonatomic) int64_t actionContext;

- (id)initWithEncryptedConversationId:(int64_t)encryptedConversationId messageRandomId:(int64_t)messageRandomId action:(int32_t)action actionContext:(int64_t)actionContext;

@end
