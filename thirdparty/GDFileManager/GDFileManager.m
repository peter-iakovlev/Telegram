//
//  GDFileManager.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 10/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileManager.h"
#import "GDFileManager_Private.h"

#import "GDDispatchUtilities.h"

#import "GDURLMetadata.h"
#import "GDURLMetadata_Private.h"

#import "GDFileManagerAlias_Private.h"

#import "GDRetainingMetadataCache.h"
#import "GDFileService.h"
#import "GDFileServiceManager.h"
#import "GDFileServiceSession.h"

#import "GDMultiMap.h"

NSString *const GDFileManagerErrorDomain = @"GDFileManagerErrorDomain";

static NSString *const GDFileManagerSharedCacheDidChange = @"GDFileManagerSharedCacheDidChange";

// Only expecting recent URLs to need caching
#define MAXIMUM_CANONICAL_URL_CACHE_SIZE 20

__attribute__((overloadable)) NSError *GDFileManagerError(NSInteger code, NSError *underlyingError)
{
    NSDictionary *userInfo = nil;
    if (underlyingError) {
        userInfo = @{NSUnderlyingErrorKey: underlyingError};
    }
    return [[NSError alloc] initWithDomain:GDFileManagerErrorDomain code:code userInfo:userInfo];
}

__attribute__((overloadable)) NSError *GDFileManagerError(NSInteger code)
{
    return GDFileManagerError(code, nil);
}

@interface GDFileManager ()

@property (nonatomic, strong) NSCache *directoryResultsCache;
@property (nonatomic, strong) NSCache *multimapDirectoryResultsCache;

@end

static NSOperationQueue *GDFileManagerLowPriorityOperationQueue = nil;

@implementation GDFileManager

+ (void)initialize
{
    if (self == [GDFileManager class]) {
        GDFileManagerLowPriorityOperationQueue = [NSOperationQueue new];
        GDFileManagerLowPriorityOperationQueue.maxConcurrentOperationCount = 1;
    }
}

+ (GDFileManager *)sharedManager
{
    static GDFileManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [GDFileManager new];
        _sharedManager.sessionCache = nil;
        _sharedManager.directoryResultsCache = nil;
        _sharedManager.multimapDirectoryResultsCache = nil;
    });
    
    return _sharedManager;
}

+ (void)enqueueLowPriorityFileManagerOperation:(NSOperation *)operation
{
    return [GDFileManagerLowPriorityOperationQueue addOperation:operation];
}

#pragma mark - Instance methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    return [self initWithFileServiceManager:nil];
}

- (id)initWithFileServiceManager:(GDFileServiceManager *)fileServiceManager
{
    if ((self = [super init])) {
        self.sessionCache = [GDRetainingMetadataCache new];
        self.directoryResultsCache = [NSCache new];
        self.multimapDirectoryResultsCache = [NSCache new];
        _fileServiceManager = fileServiceManager ?: [GDFileServiceManager sharedManager];
        
        self.defaultCachePolicy = GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOffline;
        
        _operationQueue = [NSOperationQueue new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sharedMetadataCacheDidChange:)
                                                     name:GDFileManagerSharedCacheDidChange
                                                   object:nil];
    }
    
    return self;
}

- (GDFileService *)fileServiceForURLScheme:(NSString *)urlScheme
{
    return [self.fileServiceManager fileServiceForURLScheme:urlScheme];
}

- (GDFileServiceSession *)fileServiceSessionForURL:(NSURL *)url
{
    return [self.fileServiceManager fileServiceSessionForURL:url];
}

- (NSURL *)uniqueRootURLForURLScheme:(NSString *)scheme error:(NSError *__autoreleasing *)error
{
    GDFileService *fileService = [self fileServiceForURLScheme:scheme];
    NSArray *sessions = [fileService fileServiceSessions];
    if ([sessions count] != 1) {
        if (error) *error = GDFileManagerError(GDFileManagerRootNotUniqueError);
        return nil;
    }
    NSURL *baseURL = [(GDFileServiceSession *)[sessions lastObject] baseURL];
    return [baseURL URLByAppendingPathComponent:@"/"];
}

- (NSString *)sessionNameForURL:(NSURL *)url
{
    GDFileService *service = [self fileServiceForURLScheme:[url scheme]];
    return service.name;
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    for (GDFileService *fileService in [self.fileServiceManager allFileServices]) {
        if ([fileService handleOpenURL:url])
            return YES;
    }
    return NO;
}


#pragma mark - Client methods

- (void)getContentsOfDirectoryAtURL:(NSURL *)url success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    return [self getContentsOfDirectoryAtURL:url cachePolicy:self.defaultCachePolicy success:success failure:failure];
}

- (void)getContentsOfDirectoryAtURL:(NSURL *)url cachePolicy:(GDFileManagerCachePolicy)cachePolicy
                         success:(void (^)(NSArray *contents))success failure:(void (^)(NSError *error))failure
{
    if (!success) success = ^(__unused NSArray *contents){};
    if (!failure) failure = ^(__unused NSError *error){};

    GDFileServiceSession *session = [self.fileServiceManager fileServiceSessionForURL:url];

    NSURL *canonicalURL = [session canonicalURLForURL:url];
    if (!canonicalURL) {
        return failure(GDFileManagerError(GDFileManagerNoCanonicalURLError));
    }
    
    id <GDURLMetadata> metadata = [self.sessionCache metadataForURL:canonicalURL];
    if (metadata && ![metadata isDirectory]) {
        return failure(GDFileManagerError(GDFileManagerNoCanonicalURLError));
    }
    
    NSArray *directoryContents = [self.directoryResultsCache objectForKey:url];
    if (directoryContents && cachePolicy != GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOfflineAndIgnoreSessionCache) {
        if ([directoryContents isKindOfClass:[NSArray class]])
            return success(directoryContents);
        else if ([directoryContents isKindOfClass:[NSError class]])
            return failure((NSError *)directoryContents);
    }
    
    directoryContents = [self.sessionCache directoryContentsMetadataArrayForURL:canonicalURL];
    
    if (directoryContents && cachePolicy != GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOfflineAndIgnoreSessionCache) {
        directoryContents = [session clientMetadataArrayWithCachedMetadataArray:directoryContents parentURL:url cache:nil];
        [self.directoryResultsCache setObject:directoryContents forKey:url];
        return success(directoryContents);
    }
    
    if (directoryContents
        && (cachePolicy == GDFileManagerReturnCacheDataElseDontLoad || cachePolicy == GDFileManagerReturnCacheDataElseLoad)) {
        directoryContents = [session clientMetadataArrayWithCachedMetadataArray:directoryContents parentURL:url cache:self.sessionCache];
        [self.directoryResultsCache setObject:directoryContents forKey:url];
        return success(directoryContents);
    }
    
    if (cachePolicy == GDFileManagerReturnCacheDataElseDontLoad) {
        return failure(GDFileManagerError(GDFileManagerNoResultInCacheError));
    }
    
    NSLog(@"Getting contents of directory: %@", url);
    
    [session getContentsOfDirectoryAtURL:url metadataCache:self.layeredCache
                          cachedMetadata:metadata cachedContents:directoryContents
                                 success:^(NSArray *contents) {
                                     [self.directoryResultsCache setObject:contents forKey:url];
                                     success(contents);
                                 } failure:^(NSError *error) {
                                     if ([[error domain] isEqualToString:NSURLErrorDomain] && ![session isAvailable]) {
                                         error = GDFileManagerError(GDFileManagerNetworkUnreachableError, error);
                                         if (directoryContents
                                             && (cachePolicy == GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOffline
                                                 || cachePolicy == GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOfflineAndIgnoreSessionCache)) {
                                                 
                                                 NSArray *directoryContentsClientMetadata = [session clientMetadataArrayWithCachedMetadataArray:directoryContents parentURL:url cache:nil];
                                                 [self.directoryResultsCache setObject:directoryContentsClientMetadata forKey:url];
                                                 return success(directoryContentsClientMetadata);
                                             }
                                     } else {
                                         [self.directoryResultsCache setObject:error forKey:url];
                                     }
                                     return failure(error);
                                 }];
}

- (void)getMetadataForURL:(NSURL *)url
                  success:(void (^)(GDURLMetadata *metadata))success
                  failure:(void (^)(NSError *error))failure
{
    [self getMetadataForURL:url cachePolicy:self.defaultCachePolicy success:success failure:failure];
}

- (void)getMetadataForURL:(NSURL *)url
              cachePolicy:(GDFileManagerCachePolicy)cachePolicy
                  success:(void (^)(GDURLMetadata *))success
                  failure:(void (^)(NSError *))failure
{
    if (!success) success = ^(__unused GDURLMetadata *metadata){};
    if (!failure) failure = ^(__unused NSError *error){};
    
    GDFileServiceSession *session = [self.fileServiceManager fileServiceSessionForURL:url];

    NSURL *canonicalURL = [session canonicalURLForURL:url];
    if (!canonicalURL) {
        return failure(GDFileManagerError(GDFileManagerNoCanonicalURLError));
    }
    
    id <GDURLMetadata> metadata = [self.sessionCache metadataForURL:canonicalURL];
    if (metadata && cachePolicy != GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOfflineAndIgnoreSessionCache) {
        GDURLMetadata *urlMetadata = [self clientMetadataForURLMetadata:metadata clientURL:url fileServiceSession:session cache:nil];
        return success(urlMetadata);
    }
    
    if (metadata
        && (cachePolicy == GDFileManagerReturnCacheDataElseDontLoad || cachePolicy == GDFileManagerReturnCacheDataElseLoad)) {
        GDURLMetadata *urlMetadata = [self clientMetadataForURLMetadata:metadata clientURL:url fileServiceSession:session cache:self.sessionCache];
        return success(urlMetadata);
    }
    
    if (cachePolicy == GDFileManagerReturnCacheDataElseDontLoad)
        return failure(GDFileManagerError(GDFileManagerNoResultInCacheError));
    
    NSLog(@"Getting metadata for URL: %@", url);
    
    [session getMetadataForURL:url metadataCache:self.layeredCache cachedMetadata:metadata
                       success:success
                       failure:^(NSError *error) {
                           if ([[error domain] isEqualToString:NSURLErrorDomain] && ![session isAvailable]) {
                               error = GDFileManagerError(GDFileManagerNetworkUnreachableError, error);
                               if (metadata
                                   && (cachePolicy == GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOffline
                                       || cachePolicy == GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOfflineAndIgnoreSessionCache)) {
                                   GDURLMetadata *urlMetadata = [self clientMetadataForURLMetadata:metadata clientURL:url fileServiceSession:session cache:nil];
                                   return success(urlMetadata);
                               }
                           }
                           return failure(error);
                       }];
}

- (void)getLatestVersionIdentifierForURL:(NSURL *)url
                                 success:(void (^)(NSString *versionIdentifier))success
                                 failure:(void (^)(NSError *error))failure
{
    [self getLatestVersionIdentifierForURL:url cachePolicy:self.defaultCachePolicy success:success failure:failure];
}

- (void)getLatestVersionIdentifierForURL:(NSURL *)url
                             cachePolicy:(GDFileManagerCachePolicy)cachePolicy
                                 success:(void (^)(NSString *versionIdentifier))success
                                 failure:(void (^)(NSError *error))failure
{
    if (!success) success = ^(__unused NSString *versionIdentifier){};
    if (!failure) failure = ^(__unused NSError *error){};
    
    GDFileServiceSession *session = [self.fileServiceManager fileServiceSessionForURL:url];
    
    NSURL *canonicalURL = [session canonicalURLForURL:url];
    if (!canonicalURL) {
        return failure(GDFileManagerError(GDFileManagerNoCanonicalURLError));
    }
    
    id <GDURLMetadata> metadata = [self.sessionCache metadataForURL:canonicalURL];
    if (metadata.fileVersionIdentifier && cachePolicy != GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOfflineAndIgnoreSessionCache) {
        return success(metadata.fileVersionIdentifier);
    }
    
    if (metadata.fileVersionIdentifier
        && (cachePolicy == GDFileManagerReturnCacheDataElseDontLoad || cachePolicy == GDFileManagerReturnCacheDataElseLoad)) {
        return success(metadata.fileVersionIdentifier);
    }
    
    if (cachePolicy == GDFileManagerReturnCacheDataElseDontLoad)
        return failure(GDFileManagerError(GDFileManagerNoResultInCacheError));
    
    [session getLatestVersionIdentifierForURL:canonicalURL metadataCache:self.layeredCache cachedMetadata:metadata
                                      success:success
                                      failure:^(NSError *error) {
                                          if ([[error domain] isEqualToString:NSURLErrorDomain] && ![session isAvailable]) {
                                              error = GDFileManagerError(GDFileManagerNetworkUnreachableError, error);
                                              if (metadata.fileVersionIdentifier
                                                  && (cachePolicy == GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOffline
                                                      || cachePolicy == GDFileManagerReloadRevalidatingCacheDataButReturnCacheIfOfflineAndIgnoreSessionCache)) {
                                                  return success(metadata.fileVersionIdentifier);
                                              }
                                          }
                                          return failure(error);
                                      }];

}

#pragma mark File Operations

- (void)deleteURL:(NSURL *)url success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    GDFileServiceSession *session = [self.fileServiceManager fileServiceSessionForURL:url];
    
    if ([session isReadOnly]) {
        if (failure) failure(GDFileManagerError(GDFileManagerServiceIsReadOnlyError));
        return;
    }
    
    [session deleteURL:url success:^{
        NSURL *parentURL = [session canonicalURLForURL:[url URLByDeletingLastPathComponent]];
        [self.layeredCache removeMetadataForURL:url removeFromParent:parentURL];
        [self.directoryResultsCache removeAllObjects];
        
        if (success) success();
    } failure:failure];
    
}

- (void)copyFileAtURL:(NSURL *)sourceURL toParentURL:(NSURL *)destinationParentURL name:(NSString *)name success:(void (^)(GDURLMetadata *metadata))success failure:(void (^)(NSError *))failure
{
    NSParameterAssert(name);
    GDFileServiceSession *sourceSession = [self.fileServiceManager fileServiceSessionForURL:sourceURL];
    GDFileServiceSession *destinationSession = [self.fileServiceManager fileServiceSessionForURL:destinationParentURL];
    
    if (![sourceSession isEqual:destinationSession]) {
        if (failure) failure(GDFileManagerError(GDFileManagerFileSessionsNotIdenticalError));
        return;
    }
    
    if ([sourceSession isReadOnly]) {
        if (failure) failure(GDFileManagerError(GDFileManagerServiceIsReadOnlyError));
        return;
    }
    
    [self getContentsOfDirectoryAtURL:destinationParentURL
                              success:^(NSArray *contents) {
                                  NSString *nonConflictingFilename = [sourceSession filenameAvoidingConflictsWithExistingContents:contents preferredFilename:name];
                                  [sourceSession copyFileAtURL:sourceURL toParentURL:destinationParentURL name:nonConflictingFilename success:^(GDURLMetadata *metadata){
                                      [self cacheClientMetadata:metadata addToParent:YES];
                                      
                                      if (success) success(metadata);
                                  } failure:failure];
                              } failure:failure];
}

- (void)moveFileAtURL:(NSURL *)sourceURL toParentURL:(NSURL *)destinationParentURL name:(NSString *)name success:(void (^)(GDURLMetadata *metadata))success failure:(void (^)(NSError *))failure
{
    NSParameterAssert(name);
    GDFileServiceSession *sourceSession = [self.fileServiceManager fileServiceSessionForURL:sourceURL];
    if ([sourceSession isReadOnly]) {
        if (failure) failure(GDFileManagerError(GDFileManagerServiceIsReadOnlyError));
        return;
    }
    
    if (!destinationParentURL) {
        destinationParentURL = [sourceURL URLByDeletingLastPathComponent];
    }
    
    GDFileServiceSession *destinationSession = [self.fileServiceManager fileServiceSessionForURL:destinationParentURL];
    
    if (![sourceSession isEqual:destinationSession]) {
        if (failure) failure(GDFileManagerError(GDFileManagerFileSessionsNotIdenticalError));
        return;
    }
    
    [self getContentsOfDirectoryAtURL:destinationParentURL
                              success:^(NSArray *contents) {
                                  NSString *nonConflictingFilename = [sourceSession filenameAvoidingConflictsWithExistingContents:contents preferredFilename:name];
                                  [sourceSession moveFileAtURL:sourceURL toParentURL:destinationParentURL name:nonConflictingFilename success:^(GDURLMetadata *metadata) {
                                      NSURL *sourceParentURL = [sourceSession canonicalURLForURL:[sourceURL URLByDeletingLastPathComponent]];
                                      
                                      [self.layeredCache removeMetadataForURL:sourceURL removeFromParent:sourceParentURL];
                                      [self cacheClientMetadata:metadata addToParent:YES];
                                      
                                      if (success) success(metadata);
                                  } failure:failure];
                              } failure:failure];
}



- (GDURLMetadata *)clientMetadataForURLMetadata:(id <GDURLMetadata>)metadata clientURL:(NSURL *)clientURL
                             fileServiceSession:(GDFileServiceSession *)session cache:(id <GDMetadataCache>)cache
{
    NSURL *canonicalURL = [session canonicalURLForURL:clientURL];
    GDURLMetadata *clientMetadata = [[GDURLMetadata alloc] initWithURLMetadata:metadata clientURL:clientURL canonicalURL:canonicalURL];
    if (![session shouldCacheResults])
        [cache setMetadata:clientMetadata forURL:canonicalURL];
    return clientMetadata;
}

- (void)cacheClientMetadata:(GDURLMetadata *)metadata
{
    [self cacheClientMetadata:metadata addToParent:NO];
}

- (void)cacheClientMetadata:(GDURLMetadata *)metadata addToParent:(BOOL)addToParent
{
    GDFileServiceSession *session = [self fileServiceSessionForURL:metadata.canonicalURL];
    if (![session shouldCacheResults]) return;
    
    NSURL *parentURL = nil;
    if (addToParent) {
        NSURL *nonCanonicalParentURL = [metadata.url URLByDeletingLastPathComponent];
        parentURL = [session canonicalURLForURL:nonCanonicalParentURL];
        
        [self.directoryResultsCache removeAllObjects];
    }
    
    [self.layeredCache setMetadata:metadata forURL:metadata.canonicalURL addToParent:parentURL];
}

- (void)cacheClientMetadataContents:(NSArray *)contents forURL:(NSURL *)url
{
    if (!url) return;
    GDFileServiceSession *session = [self fileServiceSessionForURL:url];
    if (![session shouldCacheResults]) return;
    
    NSMutableArray *childURLs = [NSMutableArray arrayWithCapacity:[contents count]];
    for (GDURLMetadata *childMetadata in contents) {
        [childURLs addObject:childMetadata.canonicalURL];
        [self.layeredCache setMetadata:childMetadata forURL:childMetadata.canonicalURL];
    }
    [self.layeredCache setDirectoryContents:[childURLs copy] forURL:url];
}

#pragma mark - Item finding by path

- (void)findItemsMatchingPath:(NSString *)path relativeToURL:(NSURL *)baseURL
                      success:(void (^)(NSArray *matchingMetadata))success
                      failure:(void (^)(NSError *error))failure
{
    GDFileServiceSession *session = [self.fileServiceManager fileServiceSessionForURL:baseURL];

    NSArray *pathComponents = [[session normalisedPathForPath:path] pathComponents];
    if ([pathComponents count] == 0) {
        [self getMetadataForURL:baseURL
                        success:^(GDURLMetadata *metadata) {
                            if (success) {
                                success(@[metadata]);
                            }
                        } failure:failure];
        return;
    }
    
    GDMultiMap *multimap = [self.multimapDirectoryResultsCache objectForKey:baseURL];
    if (multimap) {
        [self _findItemsMatchingPath:path relativeToURL:baseURL multimap:multimap success:success failure:failure];
    } else {
        [self getContentsOfDirectoryAtURL:baseURL
                                  success:^(NSArray *contents) {
                                      GDMultiMap *multimap = [GDMultiMap new];
                                      for (GDURLMetadata *metadata in contents) {
                                          NSString *normalisedFilename = [session normalisedPathForPath:metadata.filename];
                                          [multimap addObject:metadata forKey:normalisedFilename];
                                      }
                                      [self.multimapDirectoryResultsCache setObject:multimap forKey:baseURL];
                                      [self _findItemsMatchingPath:path relativeToURL:baseURL multimap:multimap success:success failure:failure];
                                  } failure:failure];
    }
    
}

- (void)_findItemsMatchingPath:(NSString *)path relativeToURL:(NSURL *)baseURL multimap:(GDMultiMap *)multimap
                       success:(void (^)(NSArray *matchingMetadata))success
                       failure:(void (^)(NSError *error))__unused failure
{
    __block NSError *lastError = nil;
    GDFileServiceSession *session = [self.fileServiceManager fileServiceSessionForURL:baseURL];
    NSArray *pathComponents = [[session normalisedPathForPath:path] pathComponents];
    
    NSString *firstPathComponent = pathComponents[0];
    NSMutableArray *results = [NSMutableArray new];
    
    BOOL isLastPathComponent = ([pathComponents count] == 1);
    if (isLastPathComponent) {
        for (GDURLMetadata *metadata in [multimap objectsForKey:firstPathComponent]) {
            NSString *normalisedMetadataFilename = [session normalisedPathForPath:metadata.filename];
            if ([normalisedMetadataFilename isEqualToString:firstPathComponent])
                [results addObject:metadata];
        }
        if (success) success([results copy]);
    } else {
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t results_queue = dispatch_queue_create("me.grahamdennis.GDFileManager.findMatchingItems", DISPATCH_QUEUE_SERIAL);
        
        for (GDURLMetadata *metadata in [multimap objectsForKey:firstPathComponent]) {
            if ([metadata isDirectory]) {
                // This wasn't the last element, but we found a matching directory. Recurse.
                NSString *newPath = [NSString pathWithComponents:[pathComponents subarrayWithRange:NSMakeRange(1, [pathComponents count]-1)]];
                dispatch_group_enter(group);
                [self findItemsMatchingPath:newPath relativeToURL:metadata.url success:^(NSArray *matchingMetadata) {
                    dispatch_async(results_queue, ^{
                        [results addObjectsFromArray:matchingMetadata];
                        dispatch_group_leave(group);
                    });
                } failure:^(NSError *error) {
                    dispatch_async(results_queue, ^{
                        lastError = error;
                        dispatch_group_leave(group);
                    });
                }];
            }
        }
        
        dispatch_group_notify(group, results_queue, ^{
            if (success) success([results copy]);
#if !OS_OBJECT_USE_OBJC
            dispatch_release(group);
            dispatch_release(results_queue);
#endif
        });
    }
}



#pragma mark - Aliases

- (void)createAliasForURL:(NSURL *)url
                  success:(void (^)(GDFileManagerAlias *alias))success
                  failure:(void (^)(NSError *error))failure
{
    if (!url) {
        return failure(nil);
    }
    NSArray *pathComponents = [url pathComponents];
    NSMutableArray *urlsNeedingMetadata = [NSMutableArray arrayWithObject:url];
    for (NSInteger i=[pathComponents count]-1; i>0; i--) {
        url = [url URLByDeletingLastPathComponent];
        NSString *path = [url path];
        if ([path isEqualToString:@""] || [path isEqualToString:@"/"]) {
        } else
            [urlsNeedingMetadata addObject:url];
    }
    NSMutableArray *metadataHeirarchy = [NSMutableArray arrayWithCapacity:[urlsNeedingMetadata count]];
    
    __block NSError *lastError = nil;
    
    AsyncSequentialEnumeration([urlsNeedingMetadata reverseObjectEnumerator], ^(NSURL *url, AsyncSequentialEnumerationContinuationBlock continuationBlock) {
        [self getMetadataForURL:url success:^(GDURLMetadata *metadata) {
            [metadataHeirarchy addObject:metadata];
            continuationBlock(YES);
        } failure:^(NSError *error) {
            lastError = error;
            [metadataHeirarchy removeAllObjects];
            continuationBlock(YES);
        }];
    }, ^(__unused BOOL completed) {
        if ([metadataHeirarchy count] == 0) {
            if (failure) dispatch_async(dispatch_get_main_queue(),^{failure(lastError);});
            return;
        }
        
        GDFileManagerAlias *alias = [[GDFileManagerAlias alloc] initWithMetadataHeirarchy:metadataHeirarchy];
        if (success) dispatch_async(dispatch_get_main_queue(), ^{success(alias);});
    });
}

- (void)resolveAlias:(GDFileManagerAlias *)alias
             success:(void (^)(GDURLMetadata *metadata, GDFileManagerAlias *updatedAlias))success
             failure:(void (^)(NSError *error))failure
{
    if (!alias) {
        if (failure) failure(nil);
        return;
    }
    // The resolution scheme is that we prefer following the pathname over following the URL.
    // That means we should start at the root and work our way up using pathname
    // But when we fail, we need to try resolving based on the canonical URL, the trick there is then working out how to get parent information from the canonical URL.
    // We might be able to get that information from the metadata, it might be obvious to the client, or we might have some information in our persistent metadata cache.
    // If we need to resolve based on something else, then some services provide an objectID which will be valid if the file was moved, and may provide information about the
    // parent folders.  Let's first try to solve the problem
    
    NSString *originalPath = [alias originalFilenamePath];
    NSURL *originalURL = [alias originalURL];
    
    GDFileServiceSession *session = [self.fileServiceManager fileServiceSessionForURL:originalURL];
    if (!session) {
        if (failure) failure(nil);
        return;
    }
    
    NSURL *baseURL = [session baseURL];
    NSURL *originalCanonicalURL = [session canonicalURLForURL:originalURL];
    
    [self findItemsMatchingPath:originalPath relativeToURL:baseURL
                        success:^(NSArray *matchingMetadata) {
                            GDURLMetadata *bestMatch = nil;
                            // If we found a match, we just need to find the best
                            if ([matchingMetadata count] > 1) {
                                // Prefer the one that matches the canonical URL if possible.
                                for (GDURLMetadata *metadata in matchingMetadata) {
                                    if ([metadata.canonicalURL isEqual:originalCanonicalURL]) {
                                        bestMatch = metadata;
                                        break;
                                    }
                                }
                            }
                            // If none match the canonical URL, (or there's only one), take one
                            if (!bestMatch && [matchingMetadata count]) {
                                bestMatch = [matchingMetadata lastObject];
                            }
                            // We found a match!
                            if (bestMatch) {
                                if (success) success(bestMatch, nil);
                                return;
                            }
                            
                            // The files have been renamed, try to locate based on canonical URLs which may be object IDs.
                            NSMutableArray *urlsToTry = [NSMutableArray arrayWithObject:originalURL];
                            // If the canonical URL is different to the original URL, try to create an alias for it if we can't
                            // create one for the original URL.
                            if (![originalCanonicalURL isEqual:originalURL])
                                [urlsToTry addObject:originalCanonicalURL];
                            
                            __block NSError *lastError = nil;
                            
                            AsyncSequentialEnumeration([urlsToTry objectEnumerator], ^(NSURL *url, AsyncSequentialEnumerationContinuationBlock continuationBlock) {
                                [self createAliasForURL:url
                                                success:^(GDFileManagerAlias *alias) {
                                                    if (success) success(alias.originalMetadata, alias);
                                                    continuationBlock(NO);
                                                } failure:^(NSError *error) {
                                                    lastError = error;
                                                    continuationBlock(YES);
                                                }];
                            }, ^(BOOL completed) {
                                if (completed) {
                                    if (failure) failure(lastError);
                                }
                            });
                        } failure:failure];
}

#pragma mark - Downloading

- (GDFileManagerDownloadOperation *)downloadOperationFromSourceURL:(NSURL *)url toLocalFileURL:(NSURL *)localURL
                                                           success:(void (^)(NSURL *, GDURLMetadata *))success
                                                           failure:(void (^)(NSError *))failure
{
    GDFileManagerDownloadOperation *downloadOperation = [[GDFileManagerDownloadOperation alloc] initWithFileManager:self sourceURL:url success:success failure:failure];
    downloadOperation.localDestinationFileURL = localURL;
    
    return downloadOperation;
}


#pragma mark - Operation enqueueing

- (void)enqueueFileManagerOperation:(NSOperation *)operation
{
    [self.operationQueue addOperation:operation];
}

- (void)enqueueLowPriorityFileManagerOperation:(NSOperation *)operation
{
    [GDFileManager enqueueLowPriorityFileManagerOperation:operation];
}

#pragma mark - Cache management

- (void)resetSessionCache
{
    [self.sessionCache reset];
}

- (void)sharedMetadataCacheDidChange:(NSNotification *)__unused notification
{
    [self _updateLayeredCache];
}

- (void)setSessionCache:(id<GDMetadataCache>)sessionCache
{
    _sessionCache = sessionCache;
    [self _updateLayeredCache];
}

- (void)_updateLayeredCache
{
    id <GDMetadataCache> sessionCache = self.sessionCache;
    
    if (sessionCache) {
        self.layeredCache = sessionCache;
    } else {
        self.layeredCache = nil;
    }
}

@end
