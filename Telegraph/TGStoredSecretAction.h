#import <Foundation/Foundation.h>

#import "PSCoding.h"

#import "TGMessage.h"
#import "TGStoredOutgoingMessageFileInfo.h"
#import "TGStoredIncomingMessageFileInfo.h"

typedef enum {
    TGStoredSecretActionWithSeqActionIdGeneric = 0,
    TGStoredSecretActionWithSeqActionIdEncrypted = 1
} TGStoredSecretActionWithSeqActionIdType;

typedef struct {
    TGStoredSecretActionWithSeqActionIdType type;
    int32_t value;
} TGStoredSecretActionWithSeqActionId;

#ifdef __cplusplus
extern "C" {
#endif
TGStoredSecretActionWithSeqActionId TGStoredSecretActionWithSeqActionIdMake(TGStoredSecretActionWithSeqActionIdType type, int32_t value);
#ifdef __cplusplus
}
#endif

@interface TGStoredSecretActionWithSeq : NSObject

@property (nonatomic, readonly) TGStoredSecretActionWithSeqActionId actionId;
@property (nonatomic, strong, readonly) id<PSCoding> action;
@property (nonatomic, readonly) int32_t seqIn;
@property (nonatomic, readonly) int32_t seqOut;

- (instancetype)initWithActionId:(TGStoredSecretActionWithSeqActionId)actionId action:(id<PSCoding>)action seqIn:(int32_t)seqIn seqOut:(int32_t)seqOut;

@end

@interface TGStoredSecretIncomingActionWithSeq : NSObject

@property (nonatomic, strong, readonly) id<PSCoding> action;
@property (nonatomic, readonly) int32_t seqIn;
@property (nonatomic, readonly) int32_t seqOut;
@property (nonatomic, readonly) NSUInteger layer;

- (instancetype)initWithAction:(id<PSCoding>)action seqIn:(int32_t)seqIn seqOut:(int32_t)seqOut layer:(NSUInteger)layer;

@end

@interface TGStoredOutgoingMessageSecretAction : NSObject <PSCoding>

@property (nonatomic, readonly) int64_t randomId;
@property (nonatomic, readonly) NSUInteger layer;
@property (nonatomic, readonly) int64_t keyId;
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) TGStoredOutgoingMessageFileInfo *fileInfo;

- (instancetype)initWithRandomId:(int64_t)randomId layer:(NSUInteger)layer keyId:(int64_t)keyId data:(NSData *)data fileInfo:(TGStoredOutgoingMessageFileInfo *)fileInfo;

@end

@interface TGStoredOutgoingServiceMessageSecretAction : NSObject <PSCoding>

@property (nonatomic, readonly) int64_t randomId;
@property (nonatomic, readonly) NSUInteger layer;
@property (nonatomic, readonly) int64_t keyId;
@property (nonatomic, strong, readonly) NSData *data;

- (instancetype)initWithRandomId:(int64_t)randomId layer:(NSUInteger)layer keyId:(int64_t)keyId data:(NSData *)data;

@end

@interface TGStoredIncomingMessageSecretAction : NSObject <PSCoding>

@property (nonatomic, readonly) NSUInteger layer;
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, strong, readonly) TGStoredIncomingMessageFileInfo *fileInfo;

- (instancetype)initWithLayer:(NSUInteger)layer data:(NSData *)data date:(int32_t)date fileInfo:(TGStoredIncomingMessageFileInfo *)fileInfo;

@end

@interface TGStoredIncomingEncryptedDataSecretAction : NSObject <PSCoding>

@property (nonatomic, readonly) int64_t keyId;

@property (nonatomic, readonly) int64_t randomId;
@property (nonatomic, readonly) int32_t chatId;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, strong, readonly) NSData *encryptedData;
@property (nonatomic, strong, readonly) TGStoredIncomingMessageFileInfo *fileInfo;

- (instancetype)initWithKeyId:(int64_t)keyId randomId:(int64_t)randomId chatId:(int32_t)chatId date:(int32_t)date encryptedData:(NSData *)encryptedData fileInfo:(TGStoredIncomingMessageFileInfo *)fileInfo;

@end

@interface TGStoredIncomingEncryptedDataSecretActionWithActionId : NSObject

@property (nonatomic, readonly) int32_t actionId;
@property (nonatomic, strong, readonly) TGStoredIncomingEncryptedDataSecretAction *action;

- (instancetype)initWithActionId:(int32_t)actionId action:(TGStoredIncomingEncryptedDataSecretAction *)action;

@end
