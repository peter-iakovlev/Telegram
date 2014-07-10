/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessage.h"

#import "TL/TLMetaScheme.h"

@interface TGMessage (Telegraph)

- (id)initWithTelegraphMessageDesc:(TLMessage *)desc;
- (id)initWithTelegraphDecryptedMessageDesc:(TLDecryptedMessage *)desc encryptedFile:(TLEncryptedFile *)encryptedFile conversationId:(int64_t)conversationId fromUid:(int)fromUid date:(int)date;

@end
