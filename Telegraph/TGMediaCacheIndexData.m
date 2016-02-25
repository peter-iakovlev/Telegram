#import "TGMediaCacheIndexData.h"

@implementation TGMediaCacheItem

- (instancetype)initWithMessageId:(int32_t)messageId type:(TGMediaCacheItemType)type filePaths:(NSArray *)filePaths {
    self = [super init];
    if (self != nil) {
        _messageId = messageId;
        _type = type;
        _filePaths = filePaths;
    }
    return self;
}

@end

@implementation TGPeerMediaCacheIndexData

- (instancetype)initWithPeerId:(int64_t)peerId itemsByType:(NSDictionary *)itemsByType {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _itemsByType = itemsByType;
    }
    return self;
}

@end

@implementation TGMutablePeerMediaCacheIndexData

- (instancetype)initWithPeerId:(int64_t)peerId {
    self = [super initWithPeerId:peerId itemsByType:[[NSMutableDictionary alloc] init]];
    if (self != nil) {
    }
    return self;
}

- (NSMutableDictionary *)mutableItemsByType {
    return ((NSMutableDictionary *)self.itemsByType);
}

@end

@implementation TGMediaCacheIndexData

- (instancetype)initWithDataByPeerId:(NSDictionary *)dataByPeerId {
    self = [super init];
    if (self != 0) {
        _dataByPeerId = dataByPeerId;
    }
    return self;
}

@end

@implementation TGEvaluatedCacheItem

- (instancetype)initWithMessageId:(int32_t)messageId type:(TGMediaCacheItemType)type filePaths:(NSArray *)filePaths totalSize:(int64_t)totalSize {
    self = [super init];
    if (self != nil) {
        _messageId = messageId;
        _type = type;
        _filePaths = filePaths;
        _totalSize = totalSize;
    }
    return self;
}

@end

@implementation TGEvaluatedPeerMediaCacheIndexData

- (instancetype)initWithPeerId:(int64_t)peerId itemsByType:(NSDictionary *)itemsByType totalSizeByType:(NSDictionary *)totalSizeByType totalSize:(int64_t)totalSize {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _itemsByType = itemsByType;
        _totalSizeByType = totalSizeByType;
        _totalSize = totalSize;
    }
    return self;
}

@end

@implementation TGEvaluatedMediaCacheIndexData

- (instancetype)initWithDataByPeerId:(NSDictionary *)dataByPeerId totalSize:(int64_t)totalSize {
    self = [super init];
    if (self != 0) {
        _dataByPeerId = dataByPeerId;
        _totalSize = totalSize;
    }
    return self;
}

@end
