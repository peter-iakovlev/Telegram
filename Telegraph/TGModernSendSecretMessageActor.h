/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernSendMessageActor.h"

#import <MTProtoKit/MTMessageEncryptionKey.h>

#import "TL/TLMetaScheme.h"

#import "SecretLayer1.h"
#import "SecretLayer17.h"
#import "SecretLayer20.h"
#import "SecretLayer23.h"
#import "SecretLayer46.h"
#import "SecretLayer66.h"

@class TGStoredOutgoingMessageFileInfo;

@interface TGModernSendSecretMessageActor : TGModernSendMessageActor

+ (NSUInteger)currentLayer;

+ (MTMessageEncryptionKey *)generateMessageKeyData:(NSData *)messageKey incoming:(bool)incoming key:(NSData *)key;
+ (int32_t)enqueueOutgoingMessageForPeerId:(int64_t)peerId layer:(NSUInteger)layer keyId:(int64_t)keyId randomId:(int64_t)randomId messageData:(NSData *)messageData storedFileInfo:(TGStoredOutgoingMessageFileInfo *)storedFileInfo watcher:(id)watcher;
+ (int32_t)enqueueOutgoingServiceMessageForPeerId:(int64_t)peerId layer:(NSUInteger)layer keyId:(int64_t)keyId randomId:(int64_t)randomId messageData:(NSData *)messageData;
+ (void)enqueueOutgoingResendMessagesForPeerId:(int64_t)peerId fromSeq:(int32_t)fromSeq toSeq:(int32_t)toSeq;
+ (void)enqueueIncomingMessagesByPeerId:(NSDictionary *)messageByPeerId;
+ (void)enqueueIncomingEncryptedMessagesByPeerId:(NSDictionary *)messageByPeerId;
+ (void)beginIncomingQueueProcessingIfNeeded:(int64_t)peerId;
+ (void)beginOutgoingQueueProcessingIfNeeded:(int64_t)peerId;
+ (void)maybeRekeyPeerId:(int64_t)peerId;

+ (NSData *)encryptMessage:(NSData *)serializedMessage key:(NSData *)key keyId:(int64_t)keyId;

+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer setTTL:(int32_t)ttl randomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer deleteMessagesWithRandomIds:(NSArray *)randomIds randomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer flushHistoryWithRandomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer readMessagesWithRandomIds:(NSArray *)randomIds randomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer screenshotMessagesWithRandomIds:(NSArray *)randomIds randomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer notifyLayer:(NSUInteger)notifyLayer randomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer resendMessagesFromSeq:(int32_t)fromSeq toSeq:(int32_t)toSeq randomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer requestKey:(int64_t)exchangeId g_a:(NSData *)g_a randomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer acceptKey:(int64_t)exchangeId g_b:(NSData *)g_b keyFingerprint:(int64_t)keyFingerprint randomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer commitKey:(int64_t)exchangeId keyFingerprint:(int64_t)keyFingerprint randomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer abortKey:(int64_t)exchangeId randomId:(int64_t)randomId;
+ (NSData *)decryptedServiceMessageActionWithLayer:(NSUInteger)layer noopRandomId:(int64_t)randomId;

- (void)sendEncryptedMessageSuccess:(int32_t)date encryptedFile:(TLEncryptedFile *)encryptedFile;
- (void)sendEncryptedMessageFailed;

- (bool)waitsForActionWithId:(int32_t)actionId;

@end
