#import <Foundation/Foundation.h>

@interface TGDialogListRemoteOffset : NSObject <NSCoding>

@property (nonatomic, readonly) int32_t date;
@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t messageId;

- (instancetype)initWithDate:(int32_t)date peerId:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId;

- (NSComparisonResult)compare:(TGDialogListRemoteOffset *)other;

@end
