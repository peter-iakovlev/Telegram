#import <SSignalKit/SSignalKit.h>

@class TGMediaAttachment;
@class TGMediaOriginInfo;

@interface TGDownloadMessage : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t messageId;

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId;

@end

@interface TGDownloadMessagesSignal : NSObject

+ (SSignal *)downloadMessages:(NSArray *)messages;
+ (SSignal *)mediaStickerpacks:(TGMediaAttachment *)attachment;

+ (SSignal *)earliestUnseenMentionMessageId:(int64_t)peerId accessHash:(int64_t)accessHash;
+ (SSignal *)clearUnseenMentions:(int64_t)peerId;

+ (SSignal *)updatedOriginInfo:(TGMediaOriginInfo *)origin identifier:(int64_t)identifier;
+ (SSignal *)remoteOriginInfo:(TGMediaOriginInfo *)origin;

@end
