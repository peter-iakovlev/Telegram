#import "TGRecentMaskStickersSignal.h"

#import "TGTelegraph.h"

#import "TGDocumentMediaAttachment.h"

#import "TGStickersSignals.h"

#import "TGAppDelegate.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGDocumentMediaAttachment+Telegraph.h"

typedef enum {
    TGStickerSyncActionAdd,
    TGStickerSyncActionDelete
} TGStickerSyncActionType;

@interface TGMaskStickerSyncAction : NSObject

@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *document;
@property (nonatomic, readonly) TGStickerSyncActionType action;

@end

@implementation TGMaskStickerSyncAction

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)document action:(TGStickerSyncActionType)action {
    self = [super init];
    if (self != nil) {
        _document = document;
        _action = action;
    }
    return self;
}

@end

@implementation TGRecentMaskStickersSignal

+ (SQueue *)queue {
    static SQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[SQueue alloc] init];
    });
    return queue;
}

static bool _syncedStickers = false;

+ (SVariable *)_recentStickers {
    static SVariable *variable = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        variable = [[SVariable alloc] init];
        [variable set:[self _loadRecentStickers]];
    });
    [[self queue] dispatch:^{
        if (!_syncedStickers) {
            _syncedStickers = true;
            [self sync];
        }
    }];
    return variable;
}

+ (NSMutableArray *)_stickerActions {
    static NSMutableArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [[NSMutableArray alloc] init];
    });
    return array;
}

+ (NSInteger)maxSavedStickers {
    NSData *data = [TGDatabaseInstance() customProperty:@"maxSavedStickers"];
    int32_t value = 0;
    
    if (data.length >= 4) {
        [data getBytes:&value length:4];
    }
    
    return value <= 0 ? 200 : value;
}

+ (void)_enqueueStickerActions:(NSArray<TGMaskStickerSyncAction *> *)actions {
    [[self queue] dispatch:^{
        NSInteger index = -1;
        for (TGMaskStickerSyncAction *action in actions) {
            for (TGMaskStickerSyncAction *listAction in [self _stickerActions]) {
                index++;
                if (listAction.document.documentId == action.document.documentId) {
                    [[self _stickerActions] removeObjectAtIndex:index];
                    break;
                }
            }
            
            [[self _stickerActions] addObject:action];
        }
        
        [self sync];
    }];
}

+ (SSignal *)_loadRecentStickers {
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *data = [NSData dataWithContentsOfFile:[self filePath]];
        if (data == nil) {
            [subscriber putNext:@[]];
            [subscriber putCompletion];
        } else {
            NSArray *array = nil;
            @try {
                array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            } @catch (NSException *e) {
            }
            if (array == nil) {
                [subscriber putNext:@[]];
                [subscriber putCompletion];
            } else {
                [subscriber putNext:array];
                [subscriber putCompletion];
            }
        }
        
        return nil;
    }] startOn:[self queue]];
}

+ (int32_t)hashForDocumentsReverse:(NSArray *)documents {
    uint32_t acc = 0;
    
    for (TGDocumentMediaAttachment *document in [documents reverseObjectEnumerator]) {
        uint32_t low = (int32_t)(document.documentId & 0xffffffff);
        uint32_t high = (int32_t)((document.documentId >> 32) & 0xffffffff);
        acc = (acc * 20261) + high;
        acc = (acc * 20261) + low;
    }
    return acc % 0x7FFFFFFF;
}

+ (void)sync {
    if (TGTelegraphInstance.clientUserId != 0) {
        [[self queue] dispatch:^{
            [TGTelegraphInstance.genericTasksSignalManager startStandaloneSignalIfNotRunningForKey:@"syncMaskStickers" producer:^SSignal *{
                return [self _syncRecentStickers];
            }];
        }];
    }
}

+ (SSignal *)_syncRecentStickers {
    return [[SSignal defer:^SSignal *{
        NSArray *actions = [[NSArray alloc] initWithArray:[self _stickerActions]];
        [[self _stickerActions] removeAllObjects];
        
        SSignal *actionsSignal = [SSignal complete];
        
        for (TGMaskStickerSyncAction *action in actions) {
            TLRPCmessages_saveRecentSticker$messages_saveRecentSticker *saveSticker = [[TLRPCmessages_saveRecentSticker$messages_saveRecentSticker alloc] init];
            
            
            TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
            inputDocument.n_id = action.document.documentId;
            inputDocument.access_hash = action.document.accessHash;
            saveSticker.n_id = inputDocument;
            switch (action.action) {
                case TGStickerSyncActionAdd:
                    saveSticker.unsave = false;
                    break;
                case TGStickerSyncActionDelete:
                    saveSticker.unsave = true;
                    break;
            }
            actionsSignal = [actionsSignal then:[[[[TGTelegramNetworking instance] requestSignal:saveSticker] mapToSignal:^SSignal *(__unused id next) {
                return [SSignal complete];
            }] catch:^SSignal *(__unused id error) {
                return [SSignal complete];
            }]];
        }
        
        return [[actionsSignal then:[[self _loadRecentStickers] mapToSignal:^SSignal *(NSArray *array) {
            TLRPCmessages_getRecentStickers$messages_getRecentStickers *getRecentStickers = [[TLRPCmessages_getRecentStickers$messages_getRecentStickers alloc] init];
            getRecentStickers.flags = (1 << 0);
            getRecentStickers.n_hash = [self hashForDocumentsReverse:array];
            
            return [[[TGTelegramNetworking instance] requestSignal:getRecentStickers] mapToSignal:^SSignal *(id result) {
                if ([result isKindOfClass:[TLmessages_RecentStickers$messages_recentStickers class]]) {
                    TLmessages_RecentStickers$messages_recentStickers *recentStickers = result;
                    
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (id desc in [recentStickers.stickers reverseObjectEnumerator]) {
                        TGDocumentMediaAttachment *document = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:desc];
                        if (document.documentId != 0) {
                            [array addObject:document];
                        }
                    }
                    
                    int32_t localHash = [self hashForDocumentsReverse:array];
                    if (localHash != recentStickers.n_hash) {
                        TGLog(@"(TGRecentMaskStickersSignal hash mismatch)");
                    }
                    
                    [self _storeRecentStickers:array];
                    
                    [[self _recentStickers] set:[SSignal single:array]];
                    
                    return [SSignal complete];
                } else {
                    return [SSignal complete];
                }
            }];
        }]] then:[[SSignal defer:^SSignal *{
            if ([self _stickerActions].count == 0) {
                return [SSignal complete];
            } else {
                return [self _syncRecentStickers];
            }
        }] startOn:[self queue]]];
    }] startOn:[self queue]];
}

+ (NSString *)filePath {
    return [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"recentMaskStickers.data"];
}

+ (void)_storeRecentStickers:(NSArray *)array {
    [[self queue] dispatch:^{
        [[NSKeyedArchiver archivedDataWithRootObject:array] writeToFile:[self filePath] atomically:true];
    }];
}

+ (void)clearRecentStickers {
    [[self queue] dispatch:^{
        [self _storeRecentStickers:@[]];
        [[self _recentStickers] set:[SSignal single:@[]]];
        [[self _stickerActions] removeAllObjects];
        _syncedStickers = false;
    }];
}

+ (void)addRecentStickersFromDocuments:(NSArray<TGDocumentMediaAttachment *> *)documents {
    NSMutableArray *enqueuedActions = [[NSMutableArray alloc] init];
    for (TGDocumentMediaAttachment *document in documents) {
        [enqueuedActions addObject:[[TGMaskStickerSyncAction alloc] initWithDocument:document action:TGStickerSyncActionAdd]];
    }
    
    SSignal *signal = [[[[self _recentStickers] signal] take:1] map:^id(NSArray *currentDocuments) {
        NSMutableArray *updatedDocuments = [[NSMutableArray alloc] initWithArray:currentDocuments];
        for (TGDocumentMediaAttachment *addedDocument in documents) {
            int64_t documentId = addedDocument.documentId;
            NSInteger index = -1;
            for (TGDocumentMediaAttachment *document in updatedDocuments) {
                index++;
                if (document.documentId == documentId) {
                    [updatedDocuments removeObjectAtIndex:index];
                    break;
                }
            }
            [updatedDocuments addObject:addedDocument];
            NSUInteger limit = [self maxSavedStickers];
            if (updatedDocuments.count > limit) {
                [updatedDocuments removeObjectsInRange:NSMakeRange(0, updatedDocuments.count - limit)];
            }
        }
        
        [self _storeRecentStickers:updatedDocuments];
        
        return updatedDocuments;
    }];
    [signal startWithNext:^(id next) {
        [[self _recentStickers] set:[SSignal single:next]];
    }];
    
    [self _enqueueStickerActions:enqueuedActions];
}

+ (void)addRemoteRecentStickerFromDocuments:(NSArray *)addedDocuments {
    SSignal *signal = [[[[self _recentStickers] signal] take:1] map:^id(NSArray *documents) {
        NSMutableArray *updatedDocuments = [[NSMutableArray alloc] initWithArray:documents];
        for (TGDocumentMediaAttachment *addedDocument in addedDocuments) {
            int64_t documentId = addedDocument.documentId;
            NSInteger index = -1;
            for (TGDocumentMediaAttachment *document in updatedDocuments) {
                index++;
                if (document.documentId == documentId) {
                    [updatedDocuments removeObjectAtIndex:index];
                    break;
                }
            }
            [updatedDocuments addObject:addedDocument];
        }
        NSUInteger limit = [self maxSavedStickers];
        if (updatedDocuments.count > limit) {
            [updatedDocuments removeObjectsInRange:NSMakeRange(0, updatedDocuments.count - limit)];
        }
        
        [self _storeRecentStickers:updatedDocuments];
        
        return updatedDocuments;
    }];
    [signal startWithNext:^(id next) {
        [[self _recentStickers] set:[SSignal single:next]];
    }];
}

+ (void)removeRecentStickerByDocumentId:(int64_t)documentId {
    SSignal *signal = [[[[self _recentStickers] signal] take:1] map:^id(NSArray *documents) {
        NSMutableArray *updatedDocuments = [[NSMutableArray alloc] initWithArray:documents];
        NSInteger index = -1;
        for (TGDocumentMediaAttachment *document in updatedDocuments) {
            index++;
            if (document.documentId == documentId) {
                [self _enqueueStickerActions:@[[[TGMaskStickerSyncAction alloc] initWithDocument:document action:TGStickerSyncActionDelete]]];
                [updatedDocuments removeObjectAtIndex:index];
                break;
            }
        }
        
        [self _storeRecentStickers:updatedDocuments];
        
        return updatedDocuments;
    }];
    [signal startWithNext:^(id next) {
        [[self _recentStickers] set:[SSignal single:next]];
    }];
}

+ (SSignal *)recentStickers {
    return [[self _recentStickers] signal];
}

@end
