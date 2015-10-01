#import <SSignalKit/SSignalKit.h>

@interface TGDownloadMessage : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t messageId;

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId;

@end

@interface TGDownloadMessagesSignal : NSObject

+ (SSignal *)downloadMessages:(NSArray *)messages;

@end
