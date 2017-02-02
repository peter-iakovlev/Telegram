#import "MultipartFetch.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"
#import "MediaBoxContexts.h"

@interface MultipartPendingPart : NSObject

@property (nonatomic, readonly) int32_t size;
@property (nonatomic, strong, readonly) id<SDisposable> disposable;

@end

@implementation MultipartPendingPart

- (instancetype)initWithSize:(int32_t)size disposable:(id<SDisposable>)disposable {
    self = [super init];
    if (self != nil) {
        _size = size;
        _disposable = disposable;
    }
    return self;
}

@end

@interface MultipartFetchManager : NSObject {
    int32_t _parallelParts;
    int32_t _defaultPartSize;
    
    SQueue *_queue;
    
    int32_t _committedOffset;
    NSRange _range;
    NSNumber *_completeSize;
    
    SSignal *(^_fetchPart)(int32_t, int32_t);
    void (^_partReady)(NSData *);
    void (^_completed)();
    
    NSMutableDictionary<NSNumber *, MultipartPendingPart *> *_fetchingParts;
    NSMutableDictionary<NSNumber *, NSData *> *_fetchedParts;
}

@end

@implementation MultipartFetchManager

- (instancetype)initWithSize:(NSNumber *)size range:(NSRange)range fetchPart:(SSignal *(^)(int32_t, int32_t))fetchPart partReady:(void (^)(NSData *))partReady completed:(void (^)())completed {
    self = [super init];
    if (self != nil) {
        _defaultPartSize = 128 * 1024;
        _queue = [[SQueue alloc] init];
        
        _fetchingParts = [[NSMutableDictionary alloc] init];
        _fetchedParts = [[NSMutableDictionary alloc] init];
        
        _completeSize = size;
        if (size != nil) {
            _range = NSMakeRange(range.location, MIN(range.location + range.length, (NSUInteger)[size intValue]));
            _parallelParts = 4;
        } else {
            _range = range;
            _parallelParts = 1;
        }
        _committedOffset = (int32_t)range.location;
        _fetchPart = [fetchPart copy];
        _partReady = [partReady copy];
        _completed = [completed copy];
    }
    return self;
}

- (void)start {
    [_queue dispatch:^{
        [self checkState];
    }];
}

- (void)cancel {
    [_queue dispatch:^{
        for (MultipartPendingPart *part in _fetchingParts.allValues) {
            [part.disposable dispose];
        }
    }];
}

- (void)checkState {
    for (NSNumber *nOffset in [_fetchedParts.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        if ([nOffset intValue] == _committedOffset) {
            NSData *data = _fetchedParts[nOffset];
            _committedOffset += (int32_t)data.length;
            [_fetchedParts removeObjectForKey:nOffset];
            _partReady(data);
        }
    }
    
    if (_completeSize != nil && _committedOffset >= [_completeSize intValue]) {
        _completed();
    } else if ((NSUInteger)_committedOffset >= _range.location + _range.length) {
        _completed();
    } else {
        while ((int32_t)(_fetchingParts.count) < _parallelParts) {
            __block int32_t nextOffset = _committedOffset;
            [_fetchingParts enumerateKeysAndObjectsUsingBlock:^(NSNumber *nOffset, MultipartPendingPart *part, __unused BOOL *stop) {
                nextOffset = MAX(nextOffset, [nOffset intValue] + part.size);
            }];
            
            [_fetchedParts enumerateKeysAndObjectsUsingBlock:^(NSNumber *nOffset, NSData *data, __unused BOOL *stop) {
                nextOffset = MAX(nextOffset, [nOffset intValue] + ((int32_t)data.length));
            }];
            
            NSUInteger upperBound = _range.location + _range.length;
            if (_completeSize != nil) {
                upperBound = MIN(upperBound, (NSUInteger)[_completeSize intValue]);
            }
            
            __weak MultipartFetchManager *weakSelf = self;
            if ((NSUInteger)nextOffset < upperBound) {
                
                int32_t partSize = (int32_t)(MIN(upperBound - (NSUInteger)nextOffset, (NSUInteger)_defaultPartSize));
                
                SSignal *part = [_fetchPart(nextOffset, partSize) deliverOn:_queue];
                int32_t partOffset = nextOffset;
                _fetchingParts[@(nextOffset)] = [[MultipartPendingPart alloc] initWithSize:partSize disposable:[part startWithNext:^(NSData *data) {
                    __strong MultipartFetchManager *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        NSData *clippedData = data;
                        if ((int32_t)data.length > partSize) {
                            clippedData = [data subdataWithRange:NSMakeRange(0, partSize)];
                        }
                        if (strongSelf->_completeSize != nil) {
                            assert((int32_t)data.length == partSize);
                        } else if ((int32_t)data.length < partSize) {
                            strongSelf->_completeSize = @(partOffset + (int32_t)data.length);
                        }
                        [strongSelf->_fetchingParts removeObjectForKey:@(partOffset)];
                        strongSelf->_fetchedParts[@(partOffset)] = data;
                        [strongSelf checkState];
                    }
                }]];
            } else {
                break;
            }
        }
    }
}

@end

SSignal *multipartFetch(id<TelegramCloudMediaResource> resource, __unused NSNumber *size, NSRange range, TGNetworkMediaTypeTag mediaTypeTag) {
    return [[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:[resource datacenterId] type:mediaTypeTag] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker) {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            SSignal *(^fetchPart)(int32_t, int32_t) = ^SSignal *(int32_t offset, int32_t limit) {
                TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
                getFile.location = [resource apiInputLocation];
                getFile.offset = offset;
                getFile.limit = limit;
                return [[[TGTelegramNetworking instance] requestSignal:getFile worker:worker] mapToSignal:^SSignal *(id next) {
                    if ([next isKindOfClass:[TLupload_File class]]) {
                        TLupload_File *part = next;
                        return [SSignal single:part.bytes];
                    } else {
                        return [SSignal complete];
                    }
                }];
            };
            
            MultipartFetchManager *manager = [[MultipartFetchManager alloc] initWithSize:size range:range fetchPart:fetchPart partReady:^(NSData *data) {
                [subscriber putNext:[[MediaResourceDataFetchResult alloc] initWithData:data complete:false]];
            } completed:^{
                [subscriber putNext:[[MediaResourceDataFetchResult alloc] initWithData:[NSData data] complete:true]];
            }];
            
            [manager start];
            
            return [[SBlockDisposable alloc] initWithBlock:^{
                [manager cancel];
            }];
        }];
    }];
}
