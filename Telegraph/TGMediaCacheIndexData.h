#import <Foundation/Foundation.h>

typedef enum {
    TGMediaCacheItemTypeImage,
    TGMediaCacheItemTypeVideo,
    TGMediaCacheItemTypeFile,
    TGMediaCacheItemTypeMusic
} TGMediaCacheItemType;

@interface TGMediaCacheItem: NSObject

@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) TGMediaCacheItemType type;
@property (nonatomic, strong, readonly) NSArray *filePaths;

- (instancetype)initWithMessageId:(int32_t)messageId type:(TGMediaCacheItemType)type filePaths:(NSArray *)filePaths;

@end

@interface TGPeerMediaCacheIndexData : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, strong, readonly) NSDictionary *itemsByType;

- (instancetype)initWithPeerId:(int64_t)peerId itemsByType:(NSDictionary *)itemsByType;

@end

@interface TGMutablePeerMediaCacheIndexData : TGPeerMediaCacheIndexData

@property (nonatomic, strong, readonly) NSMutableDictionary *mutableItemsByType;

- (instancetype)initWithPeerId:(int64_t)peerId;

@end

@interface TGMediaCacheIndexData : NSObject

@property (nonatomic, strong, readonly) NSDictionary *dataByPeerId;

- (instancetype)initWithDataByPeerId:(NSDictionary *)dataByPeerId;

@end

@interface TGEvaluatedCacheItem: NSObject

@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) TGMediaCacheItemType type;
@property (nonatomic, strong, readonly) NSArray *filePaths;
@property (nonatomic, readonly) int64_t totalSize;

- (instancetype)initWithMessageId:(int32_t)messageId type:(TGMediaCacheItemType)type filePaths:(NSArray *)filePaths totalSize:(int64_t)totalSize;

@end

@interface TGEvaluatedPeerMediaCacheIndexData : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, strong, readonly) NSDictionary *itemsByType;
@property (nonatomic, strong, readonly) NSDictionary *totalSizeByType;
@property (nonatomic, readonly) int64_t totalSize;

- (instancetype)initWithPeerId:(int64_t)peerId itemsByType:(NSDictionary *)itemsByType totalSizeByType:(NSDictionary *)totalSizeByType totalSize:(int64_t)totalSize;

@end

@interface TGEvaluatedMediaCacheIndexData : NSObject

@property (nonatomic, strong, readonly) NSDictionary *dataByPeerId;
@property (nonatomic, readonly) int64_t totalSize;

- (instancetype)initWithDataByPeerId:(NSDictionary *)dataByPeerId totalSize:(int64_t)totalSize;

@end
