#import <Foundation/Foundation.h>

#import "PSCoding.h"

#import "TGMessage.h"
#import "TGStoredOutgoingMessageFileInfo.h"
#import "TGStoredIncomingMessageFileInfo.h"

@interface TGStoredSecretActionWithSeq : NSObject

@property (nonatomic, readonly) int32_t actionId;
@property (nonatomic, strong, readonly) id<PSCoding> action;
@property (nonatomic, readonly) int32_t seqIn;
@property (nonatomic, readonly) int32_t seqOut;

- (instancetype)initWithActionId:(int32_t)actionId action:(id<PSCoding>)action seqIn:(int32_t)seqIn seqOut:(int32_t)seqOut;

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
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) TGStoredOutgoingMessageFileInfo *fileInfo;

- (instancetype)initWithRandomId:(int64_t)randomId layer:(NSUInteger)layer data:(NSData *)data fileInfo:(TGStoredOutgoingMessageFileInfo *)fileInfo;

@end

@interface TGStoredOutgoingServiceMessageSecretAction : NSObject <PSCoding>

@property (nonatomic, readonly) int64_t randomId;
@property (nonatomic, readonly) NSUInteger layer;
@property (nonatomic, strong, readonly) NSData *data;

- (instancetype)initWithRandomId:(int64_t)randomId layer:(NSUInteger)layer data:(NSData *)data;

@end

@interface TGStoredIncomingMessageSecretAction : NSObject <PSCoding>

@property (nonatomic, readonly) NSUInteger layer;
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, readonly) int32_t date;
@property (nonatomic, strong, readonly) TGStoredIncomingMessageFileInfo *fileInfo;

- (instancetype)initWithLayer:(NSUInteger)layer data:(NSData *)data date:(int32_t)date fileInfo:(TGStoredIncomingMessageFileInfo *)fileInfo;

@end

