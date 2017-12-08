#import "TGFavoriteStickersSignal.h"

#import <libkern/OSAtomic.h>

#import "TGTelegraph.h"
#import "TGAppDelegate.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGDocumentMediaAttachment+Telegraph.h"

#import "TGStickersSignals.h"

typedef enum {
    TGStickerFaveActionFave,
    TGStickerFaveActionUnfave
} TGStickerFaveActionType;

@interface TGStickerFaveAction : NSObject

@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *document;
@property (nonatomic, readonly) TGStickerFaveActionType action;

@end

@implementation TGStickerFaveAction

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)document action:(TGStickerFaveActionType)action {
    self = [super init];
    if (self != nil) {
        _document = document;
        _action = action;
    }
    return self;
}

@end

@implementation TGFavoriteStickersSignal

+ (SQueue *)queue {
    static SQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[SQueue alloc] init];
    });
    return queue;
}

static bool _syncedStickers = false;

+ (SVariable *)_favedStickers {
    static SVariable *variable = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        variable = [[SVariable alloc] init];
        [variable set:[self _loadFavedStickers]];
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

static OSSpinLock idsLock = OS_SPINLOCK_INIT;

+ (NSMutableArray *)_favedDocumentIds {
    static NSMutableArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [[NSMutableArray alloc] init];
    });
    return array;
}

+ (NSInteger)maxFavedStickers {
    NSData *data = [TGDatabaseInstance() customProperty:@"maxFavedStickers"];
    int32_t value = 0;
    
    if (data.length >= 4) {
        [data getBytes:&value length:4];
    }
    
    return value <= 0 ? 30 : value;
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

+ (void)clearFavoriteStickers {
    [[self queue] dispatch:^{
        [self _storeFavedStickers:@[]];
        [[self _favedStickers] set:[SSignal single:@[]]];
        [[self _stickerActions] removeAllObjects];
        _syncedStickers = false;
    }];
}

+ (void)sync {
    if (TGTelegraphInstance.clientUserId != 0) {
        [[self queue] dispatch:^{
            [TGTelegraphInstance.genericTasksSignalManager startStandaloneSignalIfNotRunningForKey:@"syncFavedStickers" producer:^SSignal *{
                return [self _syncFavedStickers];
            }];
        }];
    }
}

+ (void)_enqueueStickerAction:(TGStickerFaveAction *)action {
    [[self queue] dispatch:^{
        NSInteger index = -1;
        for (TGStickerFaveAction *listAction in [self _stickerActions]) {
            index++;
            if (listAction.document.documentId == action.document.documentId) {
                [[self _stickerActions] removeObjectAtIndex:index];
                break;
            }
        }
        
        [[self _stickerActions] addObject:action];
        
        [self sync];
    }];
}

+ (SSignal *)_loadFavedStickers {
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *data = [NSData dataWithContentsOfFile:[self filePath]];

        NSArray *array = nil;
        @try {
            array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        } @catch (NSException *e) {
        }
        
        [self syncFavedIds:array];
        
        if (array == nil) {
            [subscriber putNext:@[]];
            [subscriber putCompletion];
        } else {
            [subscriber putNext:array];
            [subscriber putCompletion];
        }
        
        return nil;
    }] startOn:[self queue]];
}

+ (SSignal *)_syncFavedStickers {
    return [[SSignal defer:^SSignal *{
        NSArray *actions = [[NSArray alloc] initWithArray:[self _stickerActions]];
        [[self _stickerActions] removeAllObjects];
        
        SSignal *actionsSignal = [SSignal complete];
        
        for (TGStickerFaveAction *action in actions) {
            
            TLRPCmessages_faveSticker$messages_faveSticker *faveSticker = [[TLRPCmessages_faveSticker$messages_faveSticker alloc] init];
            
            TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
            inputDocument.n_id = action.document.documentId;
            inputDocument.access_hash = action.document.accessHash;
            faveSticker.n_id = inputDocument;
            if (action.action == TGStickerFaveActionUnfave)
                faveSticker.unfave = true;

            actionsSignal = [actionsSignal then:[[[[TGTelegramNetworking instance] requestSignal:faveSticker] mapToSignal:^SSignal *(__unused id next) {
                return [SSignal complete];
            }] catch:^SSignal *(__unused id error) {
                return [SSignal complete];
            }]];
        }
        
        return [[actionsSignal then:[[self _loadFavedStickers] mapToSignal:^SSignal *(NSArray *array) {
            TLRPCmessages_getFavedStickers$messages_getFavedStickers *getFavedStickers = [[TLRPCmessages_getFavedStickers$messages_getFavedStickers alloc] init];
            getFavedStickers.n_hash = [self hashForDocumentsReverse:array];
            
            return [[[TGTelegramNetworking instance] requestSignal:getFavedStickers] mapToSignal:^SSignal *(id result) {
                if ([result isKindOfClass:[TLmessages_FavedStickers$messages_favedStickers class]]) {
                    TLmessages_FavedStickers$messages_favedStickers *favedStickers = result;
                    
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (id desc in [favedStickers.stickers reverseObjectEnumerator]) {
                        TGDocumentMediaAttachment *document = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:desc];
                        if (document.documentId != 0) {
                            [array addObject:document];
                        }
                    }
                    
                    int32_t localHash = [self hashForDocumentsReverse:array];
                    if (localHash != favedStickers.n_hash) {
                        TGLog(@"(TGFavoriteStickersSignal hash mismatch)");
                    }
                    
                    [self _storeFavedStickers:array];
                    
                    [[self _favedStickers] set:[SSignal single:array]];
                    
                    return [SSignal complete];
                } else {
                    return [SSignal complete];
                }
            }];
        }]] then:[[SSignal defer:^SSignal *{
            if ([self _stickerActions].count == 0) {
                return [SSignal complete];
            } else {
                return [self _syncFavedStickers];
            }
        }] startOn:[self queue]]];
    }] startOn:[self queue]];
}

+ (NSString *)filePath {
    return [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"favedStickers.data"];
}

+ (void)_storeFavedStickers:(NSArray *)array {
    [[self queue] dispatch:^{
        [self syncFavedIds:array];
        
        [[NSKeyedArchiver archivedDataWithRootObject:array] writeToFile:[self filePath] atomically:true];
    }];
}

+ (void)syncFavedIds:(NSArray *)array {
    OSSpinLockLock(&idsLock);
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    [[self _favedDocumentIds] removeAllObjects];
    for (TGDocumentMediaAttachment *document in array)
    {
        [ids addObject:@{@"documentId": @(document.documentId), @"dcId": @(document.datacenterId)}];
    }
    [[self _favedDocumentIds] addObjectsFromArray:ids];
    OSSpinLockUnlock(&idsLock);
}

+ (bool)isFaved:(TGDocumentMediaAttachment *)sticker
{
    bool faved = false;
    OSSpinLockLock(&idsLock);
    
    NSNumber *documentId = @(sticker.documentId);
    NSNumber *datacenterId = @(sticker.datacenterId);
    for (NSDictionary *documentPair in [self _favedDocumentIds])
    {
        if ([documentPair[@"documentId"] isEqualToNumber:documentId] && [documentPair[@"dcId"] isEqualToNumber:datacenterId])
        {
            faved = true;
            break;
        }
    }
    
    OSSpinLockUnlock(&idsLock);

    return faved;
}

+ (void)setSticker:(TGDocumentMediaAttachment *)document faved:(bool)faved
{
    if (document.documentId == 0) {
        return;
    }
    
    SSignal *signal = [[[[self _favedStickers] signal] take:1] map:^id(NSArray *documents) {
        NSMutableArray *updatedDocuments = [[NSMutableArray alloc] initWithArray:documents];
        NSInteger index = -1;
        int64_t documentId = document.documentId;
        for (TGDocumentMediaAttachment *document in updatedDocuments) {
            index++;
            if (document.documentId == documentId) {
                [updatedDocuments removeObjectAtIndex:index];
                break;
            }
        }
        if (faved)
            [updatedDocuments addObject:document];
        NSUInteger limit = [self maxFavedStickers];
        if (updatedDocuments.count > limit) {
            [updatedDocuments removeObjectsInRange:NSMakeRange(0, updatedDocuments.count - limit)];
        }
        
        [self _storeFavedStickers:updatedDocuments];
        
        if (faved && [TGDatabaseInstance() stickerPackForReference:document.stickerPackReference] == nil)
        {
            [[TGStickersSignals stickerPackInfo:document.stickerPackReference] startWithNext:^(TGStickerPack *next) {
                [TGDatabaseInstance() storeStickerPack:next forReference:next.packReference];
            }];
        }
        
        return updatedDocuments;
    }];
    [signal startWithNext:^(id next) {
        [[self _favedStickers] set:[SSignal single:next]];
    }];
    
    [self _enqueueStickerAction:[[TGStickerFaveAction alloc] initWithDocument:document action:faved ? TGStickerFaveActionFave : TGStickerFaveActionUnfave]];
}

+ (SSignal *)favoriteStickers {
    return [[self _favedStickers] signal];
}

@end
