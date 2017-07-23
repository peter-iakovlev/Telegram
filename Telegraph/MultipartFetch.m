#import "MultipartFetch.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"
#import "MediaBoxContexts.h"

#import "TGCdnFileData.h"

#import "TGNetworkWorker.h"

#import <MTProtoKit/MtProtoKit.h>

#import "MediaBoxContexts.h"

@interface MultipartFetchRequestData : NSObject
    
@property (nonatomic, strong, readonly) TGNetworkWorkerGuard *worker;
@property (nonatomic, strong, readonly) id data;

@end

@implementation MultipartFetchRequestData

- (instancetype)initWithWorker:(TGNetworkWorkerGuard *)worker data:(id)data {
    self = [super init];
    if (self != nil) {
        _worker = worker;
        _data = data;
    }
    return self;
}

@end

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
    
    id<TelegramCloudMediaResource> _resource;
    TGNetworkMediaTypeTag _mediaTypeTag;
    
    SQueue *_queue;
    
    int32_t _committedOffset;
    NSRange _range;
    NSNumber *_completeSize;
    
    void (^_partReady)(NSData *);
    void (^_completed)();
    void (^_failed)();
    
    NSMutableDictionary<NSNumber *, MultipartPendingPart *> *_fetchingParts;
    NSMutableDictionary<NSNumber *, NSData *> *_fetchedParts;
    
    SVariable *_requestData;
    bool _switchedToCdn;
    bool _reuploadedToCdn;
    
    SMetaDisposable *_reuploadToCdnDisposable;
    SMetaDisposable *_partHashesDisposable;
    
    NSDictionary *_cdnFilePartHashes;
}

@end

@implementation MultipartFetchManager

- (instancetype)initWithResource:(id<TelegramCloudMediaResource>)resource mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag size:(NSNumber *)size range:(NSRange)range partReady:(void (^)(NSData *))partReady completed:(void (^)())completed failed:(void (^)())failed {
    self = [super init];
    if (self != nil) {
        _defaultPartSize = 128 * 1024;
        _queue = [[SQueue alloc] init];
        
        _resource = resource;
        _mediaTypeTag = mediaTypeTag;
        
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
        _partReady = [partReady copy];
        _completed = [completed copy];
        _failed = [failed copy];
        
        _reuploadToCdnDisposable = [[SMetaDisposable alloc] init];
        _partHashesDisposable = [[SMetaDisposable alloc] init];
        
        _requestData = [[SVariable alloc] init];
        [_requestData set:[[SSignal combineSignals:@[[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:[resource datacenterId] type:_mediaTypeTag], [SSignal single:[resource apiInputLocation]]]] map:^id(NSArray *values) {
            return [[MultipartFetchRequestData alloc] initWithWorker:values[0] data:values[1]];
        }]];
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
        [_reuploadToCdnDisposable dispose];
        [_partHashesDisposable dispose];
    }];
}

- (void)checkState {
    for (NSNumber *nOffset in [_fetchedParts.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        if ([nOffset intValue] == _committedOffset) {
            NSData *data = _fetchedParts[nOffset];
            _committedOffset += (int32_t)data.length;
            [_fetchedParts removeObjectForKey:nOffset];
            
            if (_cdnFilePartHashes != nil) {
                NSData *dataToWrite = data;
                int32_t basePartOffset = [nOffset intValue];
                for (int32_t localOffset = 0; localOffset < (int32_t)dataToWrite.length; localOffset += 128 * 1024) {
                    int32_t partOffset = basePartOffset + localOffset;
                    NSData *hashData = _cdnFilePartHashes[@(partOffset)];
                    if (hashData == nil) {
                        TGLog(@"File CDN part hash missing at %d", partOffset);
                        _failed();
                        return;
                    }
                    NSData *localHash = nil;
                    if (partOffset + 128 * 1024 > (int32_t)dataToWrite.length) {
                        localHash = MTSha256([[NSData alloc] initWithBytesNoCopy:(void *)dataToWrite.bytes + localOffset length:(int32_t)dataToWrite.length - localOffset freeWhenDone:false]);
                    } else {
                        localHash = MTSha256([[NSData alloc] initWithBytesNoCopy:(void *)dataToWrite.bytes + localOffset length:128 * 1024 freeWhenDone:false]);
                    }
                    if (![localHash isEqual:hashData]) {
                        TGLog(@"File CDN part hash mismatch at %d", partOffset);
                        _failed();
                        return;
                    }
                }
            }
            
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
                
                int32_t updatedLimit = partSize;
                while (updatedLimit % 4096 != 0 || 1048576 % updatedLimit != 0) {
                    updatedLimit++;
                }
                
                SSignal *part = [[self fetchPart:nextOffset limit:updatedLimit] deliverOn:_queue];
                
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
    
- (SSignal *)fetchPart:(int32_t)offset limit:(int32_t)limit {
    __weak MultipartFetchManager *weakSelf = self;
    SQueue *queue = _queue;
    return [[[_requestData signal] mapToSignal:^SSignal *(MultipartFetchRequestData *requestData) {
        id requestRpc = nil;
        if ([requestData.data isKindOfClass:[TLInputFileLocation class]]) {
            TLRPCupload_getFile$upload_getFile *getFile = [[TLRPCupload_getFile$upload_getFile alloc] init];
            getFile.location = requestData.data;
            getFile.offset = offset;
            getFile.limit = limit;
            requestRpc = getFile;
        } else if ([requestData.data isKindOfClass:[TGCdnFileData class]]) {
            TGCdnFileData *fileData = requestData.data;
            TLRPCupload_getCdnFile$upload_getCdnFile *getFile = [[TLRPCupload_getCdnFile$upload_getCdnFile alloc] init];
            getFile.file_token = fileData.token;
            getFile.offset = offset;
            getFile.limit = limit;
            requestRpc = getFile;
        } else {
            return [SSignal never];
        }
        
        return [[[[TGTelegramNetworking instance] requestSignal:requestRpc worker:requestData.worker] deliverOn:queue] mapToSignal:^SSignal *(id next) {
            __strong MultipartFetchManager *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if ([next isKindOfClass:[TLupload_File$upload_file class]]) {
                    TLupload_File$upload_file *part = next;
                    return [SSignal single:part.bytes];
                } else if ([next isKindOfClass:[TLupload_File$upload_fileCdnRedirect class]]) {
                    TLupload_File$upload_fileCdnRedirect *redirect = (TLupload_File$upload_fileCdnRedirect *)next;
                    [strongSelf switchToCdn:[[TGCdnFileData alloc] initWithCdnId:redirect.dc_id token:redirect.file_token encryptionKey:redirect.encryption_key encryptionIv:redirect.encryption_iv]];
                    return [SSignal never];
                } else if ([next isKindOfClass:[TLupload_CdnFile$upload_cdnFile class]]) {
                    TGCdnFileData *fileData = (TGCdnFileData *)requestData.data;
                    NSData *bytes = ((TLupload_CdnFile$upload_cdnFile *)next).bytes;
                    NSMutableData *encryptionIv = [[NSMutableData alloc] initWithData:fileData.encryptionIv];
                    int32_t ivOffset = offset / 16;
                    ivOffset = NSSwapInt(ivOffset);
                    memcpy(encryptionIv.mutableBytes + encryptionIv.length - 4, &ivOffset, 4);
                    NSData *data = MTAesCtrDecrypt(bytes, fileData.encryptionKey, encryptionIv);
                    return [SSignal single:data];
                } else if ([next isKindOfClass:[TLupload_CdnFile$upload_cdnFileReuploadNeeded class]]) {
                    TLupload_CdnFile$upload_cdnFileReuploadNeeded *reupload = (TLupload_CdnFile$upload_cdnFileReuploadNeeded *)next;
                    TGCdnFileData *fileData = (TGCdnFileData *)requestData.data;
                    [strongSelf reuploadToCdn:fileData requestToken:reupload.request_token];
                    return [SSignal never];
                } else {
                    return [SSignal complete];
                }
            } else {
                return [SSignal complete];
            }
        }];
    }] take:1];
}

- (void)switchToCdnWithFileData:(TGCdnFileData *)fileData partHashes:(NSDictionary *)partHashes {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (partHashes != nil) {
        [dict addEntriesFromDictionary:partHashes];
    }
    int32_t maxOffset = 0;
    for (NSNumber *nOffset in dict.keyEnumerator) {
        maxOffset = MAX(maxOffset, [nOffset intValue] + 128 * 1024);
    }
    if (_completeSize != nil && maxOffset < [_completeSize intValue]) {
        if (_partHashesDisposable == nil) {
            _partHashesDisposable = [[SMetaDisposable alloc] init];
        }
        __weak MultipartFetchManager *weakSelf = self;
        
        SQueue *queue = _queue;
        [_partHashesDisposable setDisposable:[[[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:[_resource datacenterId] type:TGNetworkMediaTypeTagGeneric] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker) {
            TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes *getCdnFileHashes = [[TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes alloc] init];
            getCdnFileHashes.file_token = fileData.token;
            getCdnFileHashes.offset = maxOffset;
            return [[TGTelegramNetworking instance] requestSignal:getCdnFileHashes worker:worker];
        }] startWithNext:^(NSArray *hashes) {
            [queue dispatch:^{
                __strong MultipartFetchManager *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    for (TLCdnFileHash$cdnFileHash *nHash in hashes) {
                        dict[@(nHash.offset)] = nHash.n_hash;
                    }
                    
                    int32_t maxOffset = 0;
                    for (NSNumber *nOffset in dict.keyEnumerator) {
                        maxOffset = MAX(maxOffset, [nOffset intValue] + 128 * 1024);
                    }
                    
                    if (strongSelf->_completeSize != nil && maxOffset < [strongSelf->_completeSize intValue]) {
                        [strongSelf switchToCdnWithFileData:fileData partHashes:dict];
                    } else {
                        strongSelf->_cdnFilePartHashes = dict;
                        [strongSelf switchToCdn:fileData];
                    }
                }
            }];
        } error:nil completed:nil]];
    } else {
        _cdnFilePartHashes = dict;
        [self switchToCdn:fileData];
    }
}
    
- (void)switchToCdn:(TGCdnFileData *)fileData {
    if (_switchedToCdn) {
        return;
    }
    
    _switchedToCdn = true;
    [_requestData set:[[SSignal combineSignals:@[[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:fileData.cdnId type:_mediaTypeTag isCdn:true], [SSignal single:fileData]]] map:^id(NSArray *values) {
        return [[MultipartFetchRequestData alloc] initWithWorker:values[0] data:values[1]];
    }]];
}
    
- (void)reuploadToCdn:(TGCdnFileData *)fileData requestToken:(NSData *)requestToken {
    if (_reuploadedToCdn) {
        return;
    }
    
    _reuploadedToCdn = true;
    
    __weak MultipartFetchManager *weakSelf = self;
    [_reuploadToCdnDisposable setDisposable:[[[[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:[_resource datacenterId] type:TGNetworkMediaTypeTagGeneric] deliverOn:_queue] mapToSignal:^SSignal *(TGNetworkWorkerGuard *worker) {
        TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile *reupload = [[TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile alloc] init];
        reupload.file_token = fileData.token;
        reupload.request_token = requestToken;
        return [[TGTelegramNetworking instance] requestSignal:reupload worker:worker];
    }] startWithNext:^(__unused id next) {
        __strong MultipartFetchManager *strongSelf = weakSelf;
        if (strongSelf != nil) {
            strongSelf->_reuploadedToCdn = false;
            [strongSelf->_requestData set:[[SSignal combineSignals:@[[[TGTelegramNetworking instance] downloadWorkerForDatacenterId:fileData.cdnId type:strongSelf->_mediaTypeTag isCdn:true], [SSignal single:fileData]]] map:^id(NSArray *values) {
                return [[MultipartFetchRequestData alloc] initWithWorker:values[0] data:values[1]];
            }]];
        }
    } error:^(__unused id error) {
        __strong MultipartFetchManager *strongSelf = weakSelf;
        if (strongSelf != nil) {
        }
    } completed:nil]];
}

@end

SSignal *multipartFetch(id<TelegramCloudMediaResource> resource, NSNumber *size, NSRange range, TGNetworkMediaTypeTag mediaTypeTag) {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        MultipartFetchManager *manager = [[MultipartFetchManager alloc] initWithResource:resource mediaTypeTag:mediaTypeTag size:size range:range partReady:^(NSData *data) {
            [subscriber putNext:[[MediaResourceDataFetchResult alloc] initWithData:data complete:false]];
        } completed:^{
            [subscriber putNext:[[MediaResourceDataFetchResult alloc] initWithData:[NSData data] complete:true]];
            [subscriber putCompletion];
        } failed:^{
        }];
        
        [manager start];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            [manager cancel];
        }];
    }];
}
