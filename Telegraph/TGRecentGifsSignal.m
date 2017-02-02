#import "TGRecentGifsSignal.h"

#import "TGTelegraph.h"

#import "TGDocumentMediaAttachment.h"

#import "TGStickersSignals.h"

#import "TGAppDelegate.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGDocumentMediaAttachment+Telegraph.h"

typedef enum {
    TGGifSyncActionAdd,
    TGGifSyncActionDelete
} TGGifSyncActionType;

@interface TGGifSyncAction : NSObject

@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *document;
@property (nonatomic, readonly) TGGifSyncActionType action;

@end

@implementation TGGifSyncAction

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)document action:(TGGifSyncActionType)action {
    self = [super init];
    if (self != nil) {
        _document = document;
        _action = action;
    }
    return self;
}

@end

@implementation TGRecentGifsSignal

+ (SQueue *)queue {
    static SQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[SQueue alloc] init];
    });
    return queue;
}

static bool _syncedGifs = false;

+ (SVariable *)_recentGifs {
    static SVariable *variable = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        variable = [[SVariable alloc] init];
        [variable set:[self _loadRecentGifs]];
    });
    [[self queue] dispatch:^{
        if (!_syncedGifs) {
            _syncedGifs = true;
            [self sync];
        }
    }];
    return variable;
}

+ (NSMutableArray *)_gifActions {
    static NSMutableArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [[NSMutableArray alloc] init];
    });
    return array;
}

+ (NSInteger)maxSavedGifs {
    NSData *data = [TGDatabaseInstance() customProperty:@"maxSavedGifs"];
    int32_t value = 0;
    
    if (data.length >= 4) {
        [data getBytes:&value length:4];
    }
    
    return value <= 0 ? 200 : value;
}

+ (void)_enqueueGifAction:(TGGifSyncAction *)action {
    [[self queue] dispatch:^{
        NSInteger index = -1;
        for (TGGifSyncAction *listAction in [self _gifActions]) {
            index++;
            if (listAction.document.documentId == action.document.documentId) {
                [[self _gifActions] removeObjectAtIndex:index];
                break;
            }
        }
        
        [[self _gifActions] addObject:action];
        
        [self sync];
    }];
}

+ (SSignal *)_loadRecentGifs {
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *data = [NSData dataWithContentsOfFile:[self filePath]];
        if (data == nil) {
            data = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentGifs_v0"];
            [data writeToFile:[self filePath] atomically:true];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"recentGifs_v0"];
        }
        
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
            [TGTelegraphInstance.genericTasksSignalManager startStandaloneSignalIfNotRunningForKey:@"syncGifs" producer:^SSignal *{
                return [self _syncRecentGifs];
            }];
        }];
    }
}

+ (SSignal *)_syncRecentGifs {
    return [[SSignal defer:^SSignal *{
        NSArray *actions = [[NSArray alloc] initWithArray:[self _gifActions]];
        [[self _gifActions] removeAllObjects];
        
        SSignal *actionsSignal = [SSignal complete];
        
        for (TGGifSyncAction *action in actions) {
            TLRPCmessages_saveGif$messages_saveGif *saveGif = [[TLRPCmessages_saveGif$messages_saveGif alloc] init];
            TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
            inputDocument.n_id = action.document.documentId;
            inputDocument.access_hash = action.document.accessHash;
            saveGif.n_id = inputDocument;
            switch (action.action) {
                case TGGifSyncActionAdd:
                    saveGif.unsave = false;
                    break;
                case TGGifSyncActionDelete:
                    saveGif.unsave = true;
                    break;
            }
            actionsSignal = [actionsSignal then:[[[[TGTelegramNetworking instance] requestSignal:saveGif] mapToSignal:^SSignal *(__unused id next) {
                return [SSignal complete];
            }] catch:^SSignal *(__unused id error) {
                return [SSignal complete];
            }]];
        }
        
        return [[actionsSignal then:[[self _loadRecentGifs] mapToSignal:^SSignal *(NSArray *array) {
            TLRPCmessages_getSavedGifs$messages_getSavedGifs *getSavedGifs = [[TLRPCmessages_getSavedGifs$messages_getSavedGifs alloc] init];
            getSavedGifs.n_hash = [self hashForDocumentsReverse:array];
            
            return [[[TGTelegramNetworking instance] requestSignal:getSavedGifs] mapToSignal:^SSignal *(id result) {
                if ([result isKindOfClass:[TLmessages_SavedGifs$messages_savedGifs class]]) {
                    TLmessages_SavedGifs$messages_savedGifs *savedGifs = result;
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (id desc in [savedGifs.gifs reverseObjectEnumerator]) {
                        TGDocumentMediaAttachment *document = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:desc];
                        if (document.documentId != 0) {
                            [array addObject:document];
                        }
                    }
                    
                    int32_t localHash = [self hashForDocumentsReverse:array];
                    if (localHash != savedGifs.n_hash) {
                        TGLog(@"(TGRecentGifsSignal hash mismatch)");
                    }
                    
                    [self _storeRecentGifs:array];
                    
                    if (array.count != 0 && TGAppDelegateInstance.alwaysShowStickersMode == 0)
                    {
                        TGAppDelegateInstance.alwaysShowStickersMode = 2;
                        [TGAppDelegateInstance saveSettings];
                        
                        [TGStickersSignals dispatchStickers];
                    }
                    
                    [[self _recentGifs] set:[SSignal single:array]];
                    
                    return [SSignal complete];
                } else {
                    return [SSignal complete];
                }
            }];
        }]] then:[[SSignal defer:^SSignal *{
            if ([self _gifActions].count == 0) {
                return [SSignal complete];
            } else {
                return [self _syncRecentGifs];
            }
        }] startOn:[self queue]]];
    }] startOn:[self queue]];
}

+ (NSString *)filePath {
    return [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"recentGifs.data"];
}

+ (void)_storeRecentGifs:(NSArray *)array {
    [[self queue] dispatch:^{
        [[NSKeyedArchiver archivedDataWithRootObject:array] writeToFile:[self filePath] atomically:true];
    }];
}

+ (void)clearRecentGifs {
    [[self queue] dispatch:^{
        [self _storeRecentGifs:@[]];
        [[self _recentGifs] set:[SSignal single:@[]]];
        [[self _gifActions] removeAllObjects];
        _syncedGifs = false;
    }];
}

+ (void)addRecentGifFromDocument:(TGDocumentMediaAttachment *)document {
    if (document.documentId == 0) {
        return;
    }

    SSignal *signal = [[[[self _recentGifs] signal] take:1] map:^id(NSArray *documents) {
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
        [updatedDocuments addObject:document];
        NSUInteger limit = [self maxSavedGifs];
        if (updatedDocuments.count > limit) {
            [updatedDocuments removeObjectsInRange:NSMakeRange(0, updatedDocuments.count - limit)];
        }
        
        [self _storeRecentGifs:updatedDocuments];
        
        if (TGAppDelegateInstance.alwaysShowStickersMode == 0)
        {
            TGAppDelegateInstance.alwaysShowStickersMode = 2;
            [TGAppDelegateInstance saveSettings];
            
            [TGStickersSignals dispatchStickers];
        }
        
        return updatedDocuments;
    }];
    [signal startWithNext:^(id next) {
        [[self _recentGifs] set:[SSignal single:next]];
    }];
    
    [self _enqueueGifAction:[[TGGifSyncAction alloc] initWithDocument:document action:TGGifSyncActionAdd]];
}

+ (void)addRemoteRecentGifFromDocuments:(NSArray *)addedDocuments {
    SSignal *signal = [[[[self _recentGifs] signal] take:1] map:^id(NSArray *documents) {
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
        NSUInteger limit = [self maxSavedGifs];
        if (updatedDocuments.count > limit) {
            [updatedDocuments removeObjectsInRange:NSMakeRange(0, updatedDocuments.count - limit)];
        }
        
        [self _storeRecentGifs:updatedDocuments];
        
        if (TGAppDelegateInstance.alwaysShowStickersMode == 0)
        {
            TGAppDelegateInstance.alwaysShowStickersMode = 2;
            [TGAppDelegateInstance saveSettings];
            
            [TGStickersSignals dispatchStickers];
        }
        
        return updatedDocuments;
    }];
    [signal startWithNext:^(id next) {
        [[self _recentGifs] set:[SSignal single:next]];
    }];
}

+ (void)removeRecentGifByDocumentId:(int64_t)documentId {
    SSignal *signal = [[[[self _recentGifs] signal] take:1] map:^id(NSArray *documents) {
        NSMutableArray *updatedDocuments = [[NSMutableArray alloc] initWithArray:documents];
        NSInteger index = -1;
        for (TGDocumentMediaAttachment *document in updatedDocuments) {
            index++;
            if (document.documentId == documentId) {
                [self _enqueueGifAction:[[TGGifSyncAction alloc] initWithDocument:document action:TGGifSyncActionDelete]];
                [updatedDocuments removeObjectAtIndex:index];
                break;
            }
        }
        
        [self _storeRecentGifs:updatedDocuments];
        
        return updatedDocuments;
    }];
    [signal startWithNext:^(id next) {
        [[self _recentGifs] set:[SSignal single:next]];
    }];
}

+ (SSignal *)recentGifs {
    return [[self _recentGifs] signal];
}

@end
