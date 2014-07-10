/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernSendMessageActor.h"

#ifdef __cplusplus
#import "TGEncryption.h"
#endif

#import "TL/TLMetaScheme.h"

@interface TGModernSendSecretMessageActor : TGModernSendMessageActor

#ifdef __cplusplus
+ (MessageKeyData)generateMessageKeyData:(NSData *)messageKey incoming:(bool)incoming key:(NSData *)key;
#endif
+ (NSData *)prepareEncryptedMessage:(NSString *)text media:(TLDecryptedMessageMedia *)media randomId:(int64_t)randomId key:(NSData *)key keyId:(int64_t)keyId;
+ (NSData *)encryptMessage:(NSData *)serializedMessage key:(NSData *)key keyId:(int64_t)keyId;

- (void)sendEncryptedMessageSuccess:(int32_t)date encryptedFile:(TLEncryptedFile *)encryptedFile;
- (void)sendEncryptedMessageFailed;

@end
