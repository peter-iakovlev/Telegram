#import "TGStickersSignals.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGStickerAssociation.h"

#import "TGDocumentMediaAttachment+Telegraph.h"

#import "TGAppDelegate.h"

#import "TGPreparedLocalDocumentMessage.h"
#import "TGRemoteFileSignal.h"

#import "TGImageInfo+Telegraph.h"

static bool alreadyReloadedStickerPacksFromRemote = false;

@implementation TGStickersSignals

+ (SSignal *)updateStickerPacks
{
    return [[SSignal single:nil] mapToSignal:^SSignal *(__unused id next)
    {
        SSignal *signal = [SSignal complete];
        
        int cacheInvalidationTimeout = 60 * 60;
/*#if TARGET_IPHONE_SIMULATOR
        cacheInvalidationTimeout = 10;
#endif*/
        
        NSDictionary *cachedPacks = [self cachedStickerPacks];
        int currentTime = (int)[[NSDate date] timeIntervalSince1970];
        if (cachedPacks == nil || currentTime > [cachedPacks[@"cacheUpdateDate"] intValue] + cacheInvalidationTimeout || !alreadyReloadedStickerPacksFromRemote)
        {
            signal = [self remoteStickerPacksWithCacheHash:cachedPacks[@"cacheHash"]];
        }
        else
        {
            int delay = cacheInvalidationTimeout - (currentTime - [cachedPacks[@"cacheUpdateDate"] intValue]);
            signal = [[self remoteStickerPacksWithCacheHash:cachedPacks[@"cacheHash"]] delay:delay onQueue:[SQueue concurrentDefaultQueue]];
        }
        alreadyReloadedStickerPacksFromRemote = true;
        
        SSignal *periodicFetchSignal = [[SSignal single:nil] mapToSignal:^SSignal *(__unused id next)
        {
            NSDictionary *cachedPacks = [self cachedStickerPacks];
            return [self remoteStickerPacksWithCacheHash:cachedPacks[@"cacheHash"]];
        }];
        
        signal = [signal then:[[periodicFetchSignal delay:cacheInvalidationTimeout onQueue:[SQueue concurrentDefaultQueue]] restart]];
        
        return signal;
    }];
}

+ (void)updateShowStickerButtonModeForStickerPacks:(NSArray *)stickerPacks
{
    for (TGStickerPack *stickerPack in stickerPacks)
    {
        bool isExternalPack = true;
        if ([stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]])
            isExternalPack = false;
        
        if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]])
        {
            TGStickerPackIdReference *reference = (TGStickerPackIdReference *)stickerPack.packReference;
            if (reference.shortName.length == 0)
                isExternalPack = false;
        }
        
        if (isExternalPack)
        {
            if (TGAppDelegateInstance.alwaysShowStickersMode == 0)
            {
                TGAppDelegateInstance.alwaysShowStickersMode = 2;
                [TGAppDelegateInstance saveSettings];
            }
            
            break;
        }
    }
}

+ (bool)isStickerPackInstalled:(id<TGStickerPackReference>)packReference
{
    for (TGStickerPack *pack in [self cachedStickerPacks][@"packs"])
    {
        if ([pack.packReference isEqual:packReference])
            return true;
    }
    return false;
}

+ (NSMutableDictionary *)useCountFromOrderedReferences:(NSArray *)orderedReferences
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    int distance = 1;
    int useCount = distance;
    
    for (id<TGStickerPackReference> reference in orderedReferences.reverseObjectEnumerator)
    {
        if ([reference isKindOfClass:[TGStickerPackIdReference class]])
        {
            result[@(((TGStickerPackIdReference *)reference).packId)] = @(useCount);
            useCount += distance;
        }
    }
    
    return result;
}

+ (SSignal *)stickerPacks
{
    return [[SSignal single:nil] mapToSignal:^SSignal *(__unused id defer)
    {
        [[[TGTelegramNetworking instance] genericTasksSignalManager] startStandaloneSignalIfNotRunningForKey:@"updateStickers" producer:^SSignal *
        {
            return [[self updateStickerPacks] onNext:^(NSDictionary *dict)
            {
                [self updateShowStickerButtonModeForStickerPacks:dict[@"packs"]];
                
                [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:dict toMulticastedPipeForKey:@"stickerPacks"];
            }];
        }];
        
        SSignal *signal = [SSignal single:@{@"packs": @[], @"packUseCount": @{}}];
     
        NSMutableDictionary *cachedPacks = [self cachedStickerPacks];
        if (cachedPacks.count != 0)
            signal = [SSignal single:cachedPacks];

        signal = [signal then:[[[TGTelegramNetworking instance] genericTasksSignalManager] multicastedPipeForKey:@"stickerPacks"]];
        
        return signal;
    }];
}

+ (void)clearCache
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TG_stickerPacks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    alreadyReloadedStickerPacksFromRemote = false;
}

+ (NSDictionary *)cachedStickerPacks
{
    NSData *cachedStickerPacksData = [[NSUserDefaults standardUserDefaults] objectForKey:@"TG_stickerPacks"];
    if (cachedStickerPacksData == nil)
        return nil;
    else
    {
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:cachedStickerPacksData];
        if ([dict[@"packs"] isKindOfClass:[NSArray class]])
        {
            NSArray *cachedPacks = dict[@"packs"];
    
            NSMutableIndexSet *legacyStickerPacksIndexes = [[NSMutableIndexSet alloc] init];
            [cachedPacks enumerateObjectsUsingBlock:^(TGStickerPack *stickerPack, NSUInteger index, __unused BOOL * stop)
            {
                if ([stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]])
                    [legacyStickerPacksIndexes addIndex:index];
            }];
            
            if (legacyStickerPacksIndexes.count > 0)
            {
                NSMutableArray *filteredPacks = [cachedPacks mutableCopy];
                [filteredPacks removeObjectsAtIndexes:legacyStickerPacksIndexes];
             
                NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                updatedDict[@"packs"] = filteredPacks;
                dict = updatedDict;
                
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
            }
        }
        
        if (dict[@"packUseCount"] == nil)
        {
            NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            updatedDict[@"packUseCount"] = [self useCountFromOrderedReferences:dict[@"orderedReferences"]];
            return updatedDict;
        }
        return dict;
    }
}

+ (void)replaceCacheUpdateDate:(int32_t)cacheUpdateDate
{
    NSDictionary *currentDict = [self cachedStickerPacks];
    if (currentDict != nil)
    {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:currentDict];
        newDict[@"cacheUpdateDate"] = @(cacheUpdateDate);
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newDict];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
    }
}

+ (NSDictionary *)replaceCachedStickerPacks:(NSArray *)stickerPacks withCacheHash:(NSString *)cacheHash cacheUpdateDate:(int32_t)cacheUpdateDate
{
    NSDictionary *currentDict = [self cachedStickerPacks];
    NSDictionary *newDict = nil;
    if (currentDict.count == 0)
    {
        NSMutableArray *orderedReferences = [[NSMutableArray alloc] init];
        for (TGStickerPack *stickerPack in stickerPacks)
        {
            [orderedReferences addObject:stickerPack.packReference];
        }
        NSDictionary *packUseCount = [self useCountFromOrderedReferences:orderedReferences];
        newDict = @{@"packs": stickerPacks, @"packUseCount": packUseCount, @"cacheHash": cacheHash, @"cacheUpdateDate": @(cacheUpdateDate), @"documentIdsUseCount": @{}};
    }
    else
    {
        NSMutableSet *documentIds = [[NSMutableSet alloc] init];
        
        for (TGStickerPack *stickerPack in stickerPacks)
        {
            for (TGDocumentMediaAttachment *document in stickerPack.documents)
            {
                [documentIds addObject:@(document.documentId)];
            }
        }
        
        NSMutableDictionary *documentIdsUseCount = [[NSMutableDictionary alloc] initWithDictionary:currentDict[@"documentIdsUseCount"]];
        NSMutableArray *removedDocumentIds = [[NSMutableArray alloc] init];
        for (NSNumber *nDocumentId in documentIdsUseCount.allKeys)
        {
            if (![documentIds containsObject:nDocumentId])
                [removedDocumentIds addObject:nDocumentId];
        }
        [documentIdsUseCount removeObjectsForKeys:removedDocumentIds];
        
        NSMutableDictionary *packUseCount = [[NSMutableDictionary alloc] initWithDictionary:currentDict[@"packUseCount"]];
        
        newDict = @{@"packs": stickerPacks, @"packUseCount": packUseCount, @"cacheHash": cacheHash, @"cacheUpdateDate": @(cacheUpdateDate), @"documentIdsUseCount": documentIdsUseCount};
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newDict];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
    
    return newDict;
}

+ (void)addUseCountForDocumentId:(int64_t)documentId
{
    NSDictionary *dict = [self cachedStickerPacks];
    if (dict == nil)
        return;
    
    bool found = false;
    int64_t packId = 0;
    for (TGStickerPack *stickerPack in dict[@"packs"])
    {
        for (TGDocumentMediaAttachment *document in stickerPack.documents)
        {
            if (document.documentId == documentId)
            {
                if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]])
                    packId = ((TGStickerPackIdReference *)stickerPack.packReference).packId;
                
                found = true;
                break;
            }
        }
    }
    
    if (found)
    {
        NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary: dict];
        NSMutableDictionary *updatedDocumentIdsUseCount = [[NSMutableDictionary alloc] initWithDictionary:dict[@"documentIdsUseCount"]];
        updatedDocumentIdsUseCount[@(documentId)] = @([(NSNumber *)updatedDocumentIdsUseCount[@(documentId)] intValue] + 1);
        updatedDict[@"documentIdsUseCount"] = updatedDocumentIdsUseCount;
        
        if (packId != 0)
        {
            NSMutableDictionary *packUseCount = [[NSMutableDictionary alloc] initWithDictionary:updatedDict[@"packUseCount"]];
            packUseCount[@(packId)] = @([packUseCount[@(packId)] intValue] + 1);
            updatedDict[@"packUseCount"] = packUseCount;
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:updatedDict];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
    }
}

+ (SSignal *)remoteStickerPacksWithCacheHash:(NSString *)cacheHash
{
#if TARGET_IPHONE_SIMULATOR
    cacheHash = @"";
#endif
    
    TLRPCmessages_getAllStickers$messages_getAllStickers *getAllStickers = [[TLRPCmessages_getAllStickers$messages_getAllStickers alloc] init];
    getAllStickers.n_hash = cacheHash;
    
    return [[[TGTelegramNetworking instance] requestSignal:getAllStickers] mapToSignal:^SSignal *(TLmessages_AllStickers *result)
    {
        if ([result isKindOfClass:[TLmessages_AllStickers$messages_allStickers class]])
        {
            TLmessages_AllStickers$messages_allStickers *allStickers = (TLmessages_AllStickers$messages_allStickers *)result;
            
            NSMutableDictionary *currentStickerPacks = [self cachedStickerPacks][@"packs"];
            
            NSMutableArray *resultingPackReferences = [[NSMutableArray alloc] init];
            NSMutableArray *missingPackSignals = [[NSMutableArray alloc] init];
            
            for (TLStickerSet *resultPack in allStickers.sets)
            {
                TGStickerPackIdReference *resultPackReference = [[TGStickerPackIdReference alloc] initWithPackId:resultPack.n_id packAccessHash:resultPack.access_hash shortName:resultPack.short_name];
                
                TGStickerPack *currentPack = nil;
                for (TGStickerPack *pack in currentStickerPacks)
                {
                    if ([pack.packReference isEqual:resultPackReference])
                    {
                        currentPack = pack;
                        break;
                    }
                }
                
                if (currentPack == nil || currentPack.packHash != resultPack.n_hash)
                {
                    [missingPackSignals addObject:[self stickerPackInfo:resultPackReference packHash:resultPack.n_hash]];
                }
                
                [resultingPackReferences addObject:resultPackReference];
            }
            
            return [[SSignal combineSignals:missingPackSignals] map:^id (NSArray *additionalPacks)
            {
                NSMutableArray *finalStickerPacks = [[NSMutableArray alloc] init];
                
                for (id<TGStickerPackReference> reference in resultingPackReferences)
                {
                    TGStickerPack *foundPack = nil;
                    
                    for (TGStickerPack *pack in additionalPacks)
                    {
                        if ([pack.packReference isEqual:reference])
                        {
                            foundPack = pack;
                            break;
                        }
                    }
                    
                    if (foundPack == nil)
                    {
                        for (TGStickerPack *pack in currentStickerPacks)
                        {
                            if ([pack.packReference isEqual:reference])
                            {
                                foundPack = pack;
                                break;
                            }
                        }
                    }
                    
                    if (foundPack != nil)
                        [finalStickerPacks addObject:foundPack];
                }
                
                NSDictionary *result = [self replaceCachedStickerPacks:finalStickerPacks withCacheHash:allStickers.n_hash cacheUpdateDate:(int32_t)[[NSDate date] timeIntervalSince1970]];
                return result;
            }];
            
            /*NSMutableArray *stickerAssociations = [[NSMutableArray alloc] init];
            for (TLStickerPack *resultAssociation in allStickers.packs)
            {
                TGStickerAssociation *association = [[TGStickerAssociation alloc] initWithKey:resultAssociation.emoticon documentIds:resultAssociation.documents];
                [stickerAssociations addObject:association];
            }
            
            NSMutableArray *stickerPackTitles = [[NSMutableArray alloc] init];
            NSMutableArray *stickerPacksIds = [[NSMutableArray alloc] init];
            NSMutableDictionary *documentsByPackIdOrShortname = [[NSMutableDictionary alloc] init];
            
            for (TLStickerSet *resultPack in allStickers.sets)
            {
                TGStickerPackIdReference *packReference = [[TGStickerPackIdReference alloc] initWithPackId:resultPack.n_id packAccessHash:resultPack.access_hash shortName:resultPack.short_name];
                [stickerPacksIds addObject:packReference];
                [stickerPackTitles addObject:resultPack.title];
                NSMutableArray *emptyDocuments = [[NSMutableArray alloc] init];
                documentsByPackIdOrShortname[@(packReference.packId)] = emptyDocuments;
                documentsByPackIdOrShortname[resultPack.short_name] = emptyDocuments;
            }
            
            NSMutableArray *documents = [[NSMutableArray alloc] init];
            for (TLDocument *resultDocument in allStickers.documents)
            {
                TGDocumentMediaAttachment *document = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:resultDocument];
                if (document.documentId != 0)
                {
                    [documents addObject:document];
                    
                    for (id attribute in document.attributes)
                    {
                        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                        {
                            TGDocumentAttributeSticker *stickerAttribute = attribute;
                            if (stickerAttribute.packReference != nil)
                            {
                                NSMutableArray *packDocuments = nil;
                                if ([stickerAttribute.packReference isKindOfClass:[TGStickerPackIdReference class]])
                                {
                                    TGStickerPackIdReference *concreteReference = (TGStickerPackIdReference *)stickerAttribute.packReference;
                                    packDocuments = documentsByPackIdOrShortname[@(concreteReference.packId)];
                                }
                                else if ([stickerAttribute.packReference isKindOfClass:[TGStickerPackShortnameReference class]])
                                {
                                    TGStickerPackShortnameReference *concreteReference = (TGStickerPackShortnameReference *)stickerAttribute.packReference;
                                    packDocuments = documentsByPackIdOrShortname[concreteReference.shortName];
                                }
                                if (packDocuments != nil)
                                    [packDocuments addObject:document];
                            }
                            
                            break;
                        }
                    }
                }
            }
            
            NSMutableArray *stickerPacks = [[NSMutableArray alloc] init];
            
            NSMutableArray *defaultPackDocuments = [[NSMutableArray alloc] init];
            NSMutableArray *defaultPackStickerAssociations = [[NSMutableArray alloc] init];
            
            NSMutableSet *defaultPackDocumentIds = [[NSMutableSet alloc] init];
            for (TGDocumentMediaAttachment *document in documents)
            {
                for (id attribute in document.attributes)
                {
                    if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                    {
                        if (((TGDocumentAttributeSticker *)attribute).packReference == nil)
                        {
                            [defaultPackDocuments addObject:document];
                            [defaultPackDocumentIds addObject:@(document.documentId)];
                        }
                        break;
                    }
                }
            }
            
            for (TGStickerAssociation *association in stickerAssociations)
            {
                NSMutableArray *packAssociationDocumentIds = [[NSMutableArray alloc] init];
                for (NSNumber *documentId in association.documentIds)
                {
                    if ([defaultPackDocumentIds containsObject:documentId])
                        [packAssociationDocumentIds addObject:documentId];
                }
                
                if (packAssociationDocumentIds.count != 0)
                {
                    [defaultPackStickerAssociations addObject:[[TGStickerAssociation alloc] initWithKey:association.key documentIds:packAssociationDocumentIds]];
                }
            }
            
            [stickerPacks addObject:[[TGStickerPack alloc] initWithPackReference:[[TGStickerPackBuiltinReference alloc] init] title:@"" stickerAssociations:defaultPackStickerAssociations documents:defaultPackDocuments]];
            
            for (NSUInteger i = 0; i < stickerPacksIds.count; i++)
            {
                TGStickerPackIdReference *packReference = stickerPacksIds[i];
                NSString *packTitle = stickerPackTitles[i];
                
                NSArray *packDocuments = documentsByPackIdOrShortname[@(packReference.packId)];
                if (packDocuments.count != 0)
                {
                    NSMutableSet *packDocumentIds = [[NSMutableSet alloc] init];
                    for (TGDocumentMediaAttachment *document in packDocuments)
                    {
                        [packDocumentIds addObject:@(document.documentId)];
                    }
                    
                    NSMutableArray *packAssociations = [[NSMutableArray alloc] init];
                    for (TGStickerAssociation *association in stickerAssociations)
                    {
                        NSMutableArray *packAssociationDocumentIds = [[NSMutableArray alloc] init];
                        for (NSNumber *documentId in association.documentIds)
                        {
                            if ([packDocumentIds containsObject:documentId])
                                [packAssociationDocumentIds addObject:documentId];
                        }
                        
                        if (packAssociationDocumentIds.count != 0)
                        {
                            [packAssociations addObject:[[TGStickerAssociation alloc] initWithKey:association.key documentIds:packAssociationDocumentIds]];
                        }
                    }
                    
                    [stickerPacks addObject:[[TGStickerPack alloc] initWithPackReference:packReference title:packTitle stickerAssociations:packAssociations documents:packDocuments]];
                }
            }
            
            NSDictionary *result = [self replaceCachedStickerPacks:stickerPacks withCacheHash:allStickers.n_hash cacheUpdateDate:(int32_t)[[NSDate date] timeIntervalSince1970]];
            return [SSignal single:result];*/
        }
        
        [self replaceCacheUpdateDate:(int32_t)[[NSDate date] timeIntervalSince1970]];
        
        return [SSignal complete];
    }];
}

+ (TLInputStickerSet *)_inputStickerSetFromPackReference:(id<TGStickerPackReference>)packReference
{
    if ([packReference isKindOfClass:[TGStickerPackIdReference class]])
    {
        TLInputStickerSet$inputStickerSetID *concreteId = [[TLInputStickerSet$inputStickerSetID alloc] init];;
        concreteId.n_id = ((TGStickerPackIdReference *)packReference).packId;
        concreteId.access_hash = ((TGStickerPackIdReference *)packReference).packAccessHash;
        return concreteId;
    }
    else if ([packReference isKindOfClass:[TGStickerPackShortnameReference class]])
    {
        TLInputStickerSet$inputStickerSetShortName *concreteId = [[TLInputStickerSet$inputStickerSetShortName alloc] init];
        concreteId.short_name = ((TGStickerPackShortnameReference *)packReference).shortName;
        return concreteId;
    }
    
    return [[TLInputStickerSet$inputStickerSetEmpty alloc] init];
}

+ (SSignal *)stickerPackInfo:(id<TGStickerPackReference>)packReference
{
    return [self stickerPackInfo:packReference packHash:0];
}

+ (SSignal *)stickerPackInfo:(id<TGStickerPackReference>)packReference packHash:(int32_t)packHash
{
    TLRPCmessages_getStickerSet$messages_getStickerSet *getStickerSet = [[TLRPCmessages_getStickerSet$messages_getStickerSet alloc] init];
    getStickerSet.stickerset = [self _inputStickerSetFromPackReference:packReference];
    return [[[TGTelegramNetworking instance] requestSignal:getStickerSet] map:^id (TLmessages_StickerSet *result)
    {
        TGStickerPackIdReference *resultPackReference = [[TGStickerPackIdReference alloc] initWithPackId:result.set.n_id packAccessHash:result.set.access_hash shortName:result.set.short_name];
        
        NSMutableArray *stickerAssociations = [[NSMutableArray alloc] init];
        for (TLStickerPack *resultAssociation in result.packs)
        {
            TGStickerAssociation *association = [[TGStickerAssociation alloc] initWithKey:resultAssociation.emoticon documentIds:resultAssociation.documents];
            [stickerAssociations addObject:association];
        }

        NSMutableArray *documents = [[NSMutableArray alloc] init];
        for (TLDocument *resultDocument in result.documents)
        {
            TGDocumentMediaAttachment *document = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:resultDocument];
            if (document.documentId != 0)
            {
                [documents addObject:document];
            }
        }
        
        return [[TGStickerPack alloc] initWithPackReference:resultPackReference title:result.set.title stickerAssociations:stickerAssociations documents:documents packHash:packHash];
    }];
}

+ (SSignal *)installStickerPack:(id<TGStickerPackReference>)packReference
{
    TLRPCmessages_installStickerSet$messages_installStickerSet *installStickerSet = [[TLRPCmessages_installStickerSet$messages_installStickerSet alloc] init];
    installStickerSet.stickerset = [self _inputStickerSetFromPackReference:packReference];
    
    return [[[TGTelegramNetworking instance] requestSignal:installStickerSet] then:[[self remoteStickerPacksWithCacheHash:@""] onNext:^(NSDictionary *dict)
    {
        NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        
        NSMutableDictionary *packUseCount = [[NSMutableDictionary alloc] initWithDictionary:updatedDict[@"packUseCount"]];
        __block int maxUseCount = 1;
        [packUseCount enumerateKeysAndObjectsUsingBlock:^(__unused id key, NSNumber *nUseCount, __unused BOOL *stop)
        {
            maxUseCount = MAX(maxUseCount, [nUseCount intValue]);
        }];
        
        if ([packReference isKindOfClass:[TGStickerPackIdReference class]])
        {
            packUseCount[@(((TGStickerPackIdReference *)packReference).packId)] = @(maxUseCount + 1);
        }
        
        updatedDict[@"packUseCount"] = packUseCount;
        [self updateShowStickerButtonModeForStickerPacks:updatedDict[@"packs"]];
        
        [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:updatedDict toMulticastedPipeForKey:@"stickerPacks"];
    }]];
}

+ (SSignal *)removeStickerPack:(id<TGStickerPackReference>)packReference
{
    TLRPCmessages_uninstallStickerSet$messages_uninstallStickerSet *uninstallStickerSet = [[TLRPCmessages_uninstallStickerSet$messages_uninstallStickerSet alloc] init];
    uninstallStickerSet.stickerset = [self _inputStickerSetFromPackReference:packReference];
    
    return [[[TGTelegramNetworking instance] requestSignal:uninstallStickerSet] then:[[[self remoteStickerPacksWithCacheHash:@""] onNext:^(NSDictionary *dict)
    {
        [self updateShowStickerButtonModeForStickerPacks:dict[@"packs"]];
    }] afterNext:^(id next)
    {
        [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:next toMulticastedPipeForKey:@"stickerPacks"];
    }]];
}

+ (SSignal *)preloadedStickerPreviews:(NSArray *)documents count:(NSUInteger)count
{
    return [[SSignal single:nil] mapToSignal:^SSignal *(__unused id next)
    {
        SSignal *signal = [SSignal complete];
        
        for (NSUInteger i = 0; i < count && i < documents.count; i++)
        {
            TGDocumentMediaAttachment *document = documents[i];
            
            NSString *directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId];
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:true attributes:nil error:NULL];
            
            NSString *path = [directory stringByAppendingPathComponent:@"thumbnail-high"];
            
            NSString *thumbnailUrl = [document.thumbnailInfo imageUrlForLargestSize:NULL];
            int32_t datacenterId = 0;
            int64_t volumeId = 0;
            int32_t localId = 0;
            int64_t secret = 0;
            if (extractFileUrlComponents(thumbnailUrl, &datacenterId, &volumeId, &localId, &secret))
            {
                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    TLInputFileLocation$inputFileLocation *location = [[TLInputFileLocation$inputFileLocation alloc] init];
                    location.volume_id = volumeId;
                    location.local_id = localId;
                    location.secret = secret;
                    
                    SSignal *downloadSignal = [[TGRemoteFileSignal dataForLocation:location datacenterId:datacenterId size:0 reportProgress:false] onNext:^(id next)
                    {
                        if ([next isKindOfClass:[NSData class]])
                        {
                            TGLog(@"preloaded sticker preview to %@", path);
                            [(NSData *)next writeToFile:path atomically:true];
                        }
                    }];
                    
                    signal = [signal then:downloadSignal];
                }
            }
        }
        
        return [[signal reduceLeft:nil with:^id(__unused id current, __unused id next)
        {
            return current;
        }] then:[SSignal single:documents]];
    }];
}

@end
