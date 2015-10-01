//
//  GDFileServiceSession.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileServiceSession.h"

#import "GDURLMetadata.h"
#import "GDURLMetadata_Private.h"
#import "GDMetadataCache.h"
#import "GDFileService.h"
#import "GDDispatchUtilities.h"

@implementation GDFileServiceSession

- (id)initWithBaseURL:(NSURL *)baseURL fileService:(GDFileService *)fileService
{
    if ((self = [super init])) {
        _baseURL = baseURL;
        _fileService = fileService;
        self.userVisible = YES;
    }
    
    return self;
}

- (void)unlink
{
    
}

- (void)getContentsOfDirectoryAtURL:(NSURL *)url metadataCache:(id<GDMetadataCache>)metadataCache
                     cachedMetadata:(id<GDURLMetadata>)cachedMetadata cachedContents:(NSArray *)__unused contents
                         success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [self getMetadataForURL:url metadataCache:metadataCache cachedMetadata:cachedMetadata success:^(GDURLMetadata *metadata) {
        if ([metadata isDirectory]) {
            if (success) {
                success([metadataCache directoryContentsMetadataArrayForURL:metadata.url]);
            }
        } else {
            // FIXME
            if (failure) {
                failure(nil);
            }
        }
    } failure:failure];
}

- (NSString *)normalisedPathForPath:(NSString *)path
{
    NSString *unicodeNormalisedPath = [path precomposedStringWithCanonicalMapping];
    NSString *lowercaseURLEscapedPath = [[unicodeNormalisedPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString];
    return [lowercaseURLEscapedPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSURL *)canonicalURLForURL:(NSURL *)url
{
    static dispatch_once_t onceToken;
    static NSCache *canonicalURLCache;
    dispatch_once(&onceToken, ^{
        canonicalURLCache = [NSCache new];
        canonicalURLCache.name = @"org.telegram.CanonicalURLCache";
    });
    NSURL *canonicalURL = [canonicalURLCache objectForKey:url];
    if (!canonicalURL) {
        canonicalURL = [self _canonicalURLForURL:url];
        [canonicalURLCache setObject:canonicalURL forKey:url];
    }
    return canonicalURL;
}

- (NSURL *)_canonicalURLForURL:(NSURL *)url
{
    NSString *urlString = [url absoluteString];
    if ([urlString hasSuffix:@"/"]) {
        return [NSURL URLWithString:[urlString substringToIndex:[urlString length]-1]];
    }
    return url;
}

- (void)getLatestVersionIdentifierForURL:(NSURL *)url metadataCache:(id <GDMetadataCache>)metadataCache cachedMetadata:(id <GDURLMetadata>)cachedMetadataOrNil
                                 success:(void (^)(NSString *fileVersionIdentifier))success failure:(void (^)(NSError *error))failure
{
    [self getMetadataForURL:url metadataCache:metadataCache cachedMetadata:cachedMetadataOrNil
                    success:^(GDURLMetadata *metadata) {
                        if (success) success(metadata.fileVersionIdentifier);
                    } failure:failure];
}

- (NSOperation *)downloadURL:(NSURL *)url intoFileURL:(NSURL *)localURL
                    progress:(void (^)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                     success:(void (^)(NSURL *localURL, GDURLMetadata *metadata))success
                     failure:(void (^)(NSError *error))failure
{
    return [self downloadURL:url intoFileURL:localURL fileVersion:nil progress:progress success:success failure:failure];
}

- (void)addMetadata:(id)__unused metadata parentURL:(NSURL *)__unused parentURL toCache:(id <GDMetadataCache>)__unused cache
       continuation:(void (^)(GDURLMetadata *metadata, NSArray *metadataContents))__unused continuation
{
    [self doesNotRecognizeSelector:_cmd];
}

- (NSArray *)clientMetadataArrayWithCachedMetadataArray:(NSArray *)urlMetadataArray parentURL:(NSURL *)parentURL cache:(id<GDMetadataCache>)cache
{
    NSMutableArray *clientMetadataArray = [NSMutableArray arrayWithCapacity:[urlMetadataArray count]];
    NSMutableDictionary *keyedMetadataToCache = [NSMutableDictionary dictionaryWithCapacity:[urlMetadataArray count]];
    
    for (id <GDURLMetadata> urlMetadata in urlMetadataArray) {
        GDURLMetadata *clientMetadata = [self clientMetadataWithCachedMetadata:urlMetadata parentURL:parentURL];
        if (clientMetadata) {
            [clientMetadataArray addObject:clientMetadata];
            keyedMetadataToCache[clientMetadata.canonicalURL] = urlMetadata;
        }
    }
    [cache setDirectoryContents:[keyedMetadataToCache copy] forURL:[self canonicalURLForURL:parentURL]];
    return [clientMetadataArray copy];
}

- (NSString *)filenameAvoidingConflictsWithExistingContents:(NSArray *)contents preferredFilename:(NSString *)preferredFilename
{
    NSMutableSet *filenameSet = [NSMutableSet new];
    for (GDURLMetadata *metadata in contents) {
        NSString *filename = metadata.filename;
        if (!filename) continue;
        filename = [self normalisedPathForPath:filename];
        [filenameSet addObject:filename];
    }
    
    NSString *normalisedDestinationFilename = [self normalisedPathForPath:preferredFilename];
    if (![filenameSet containsObject:normalisedDestinationFilename])
        return preferredFilename;
    
    NSInteger numberToAppend = 1;
    NSString *baseFilename = [preferredFilename stringByDeletingPathExtension];
    NSString *pathExtension = [preferredFilename pathExtension];
    
    while (true) {
        NSString *candidateFilename = [NSString stringWithFormat:@"%@ (%@).%@", baseFilename, @(numberToAppend++), pathExtension];
        NSString *normalisedCandidate = [self normalisedPathForPath:candidateFilename];
        if (![filenameSet containsObject:normalisedCandidate])
            return candidateFilename;
    };
}

- (NSURL *)cacheURLForURL:(NSURL *)__unused canonicalURL versionIdentifier:(NSString *)__unused versionIdentifier cachedMetadata:(GDURLMetadata *__autoreleasing *)__unused cachedMetadata
{
    // Doesn't support it. That's OK.
    return nil;
}


#pragma mark - Subclasses to provide

- (BOOL)automaticallyAvoidsUploadOverwrites
{
    return NO;
}

- (BOOL)shouldCacheResults
{
    GDFileService *fileService = self.fileService;
    return [fileService shouldCacheResults];
}

- (NSString *)userDescription
{
    return nil;
}

- (NSString *)detailDescription
{
    NSString *netLoc =  (__bridge_transfer NSString *)CFURLCopyNetLocation((__bridge CFURLRef)self.baseURL);
    return [NSString stringWithFormat:@"Account ID: %@", netLoc];
}

- (GDURLMetadata *)clientMetadataWithCachedMetadata:(id <GDURLMetadata>)__unused urlMetadata parentURL:(NSURL *)__unused url
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)validateAccessWithSuccess:(void (^)())__unused success failure:(void (^)(NSError *error))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)getMetadataForURL:(NSURL *)__unused url metadataCache:(id <GDMetadataCache>)__unused metadataCache cachedMetadata:(id<GDURLMetadata>)__unused cachedMetadataOrNil
                  success:(void (^)(GDURLMetadata *metadata))__unused success failure:(void (^)(NSError *error))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)deleteURL:(NSURL *)__unused url success:(void (^)())__unused success failure:(void (^)(NSError *error))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)copyFileAtURL:(NSURL *)__unused sourceURL toParentURL:(NSURL *)__unused destinationParentURL name:(NSString *)__unused name success:(void (^)(GDURLMetadata *))__unused success failure:(void (^)(NSError *))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)moveFileAtURL:(NSURL *)__unused sourceURL toParentURL:(NSURL *)__unused destinationParentURL name:(NSString *)__unused name success:(void (^)(GDURLMetadata *))__unused success failure:(void (^)(NSError *))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
}


- (NSOperation *)downloadURL:(NSURL *)__unused url intoFileURL:(NSURL *)__unused localURL fileVersion:(NSString *)__unused fileVersionIdentifier
                    progress:(void (^)(NSInteger, NSInteger, NSInteger))__unused progress
                     success:(void (^)(NSURL *localURL, GDURLMetadata *metadata))__unused success
                     failure:(void (^)(NSError *))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSOperation *)uploadFileURL:(NSURL *)__unused localURL mimeType:(NSString *)__unused mimeType toDestinationURL:(NSURL *)__unused destinationURL parentVersionID:(NSString *)__unused parentVersionID
           internalUploadState:(id <NSCoding>)__unused internalUploadState uploadStateHandler:(void (^)(GDFileManagerUploadState * uploadState))__unused uploadStateHandler
                      progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))__unused progress
                       success:(void (^)(GDURLMetadata *metadata, NSArray *conflicts))__unused success
                       failure:(void (^)(NSError *error))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSOperation *)uploadFileURL:(NSURL *)__unused localURL filename:(NSString *)__unused filename mimeType:(NSString *)__unused mimeType toParentFolderURL:(NSURL *)__unused parentFolderURL
            uploadStateHandler:(void (^)(GDFileManagerUploadState * uploadState))__unused uploadStateHandler
                      progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))__unused progress
                       success:(void (^)(GDURLMetadata *metadata, NSArray *conflicts))__unused success
                       failure:(void (^)(NSError *error))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


@end
