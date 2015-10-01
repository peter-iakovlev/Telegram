//
//  GDFileServiceSession.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDFileManagerConstants.h"

@protocol GDMetadataCache;
@class GDURLMetadata;
@protocol GDURLMetadata;

@class GDFileService;
@class GDFileSessionUploadOperation;
@class GDFileManagerUploadState;

@interface GDFileServiceSession : NSObject

// Implementation
- (id)initWithBaseURL:(NSURL *)baseURL fileService:(GDFileService *)fileService;

- (void)unlink;

@property (nonatomic, readonly, strong) NSURL *baseURL;
@property (nonatomic, readonly, weak)   GDFileService *fileService;
@property (nonatomic, getter = isReadOnly) BOOL readOnly;
@property (nonatomic, readonly) BOOL shouldCacheResults;
@property (nonatomic, getter = isUserVisible) BOOL userVisible;

- (NSOperation *)downloadURL:(NSURL *)url intoFileURL:(NSURL *)localURL
                    progress:(void (^)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                     success:(void (^)(NSURL *localURL, GDURLMetadata *metadata))success
                     failure:(void (^)(NSError *error))failure;

// Subclasses to provide

@property (nonatomic, readonly, getter = isAvailable) BOOL available;

- (BOOL)automaticallyAvoidsUploadOverwrites;
- (void)validateAccessWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure;

- (void)getMetadataForURL:(NSURL *)url metadataCache:(id <GDMetadataCache>)metadataCache cachedMetadata:(id <GDURLMetadata>)cachedMetadataOrNil
                  success:(void (^)(GDURLMetadata *metadata))success failure:(void (^)(NSError *error))failure;

- (void)getLatestVersionIdentifierForURL:(NSURL *)url metadataCache:(id <GDMetadataCache>)metadataCache cachedMetadata:(id <GDURLMetadata>)cachedMetadataOrNil
                                 success:(void (^)(NSString *fileVersionIdentifier))success failure:(void (^)(NSError *error))failure;

- (void)getContentsOfDirectoryAtURL:(NSURL *)url metadataCache:(id <GDMetadataCache>)metadataCache
                     cachedMetadata:(id <GDURLMetadata>)cachedMetadataOrNil cachedContents:(NSArray *)contentsOrNil
                         success:(void (^)(NSArray *contents))success failure:(void (^)(NSError *error))failure;

- (void)deleteURL:(NSURL *)url success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)copyFileAtURL:(NSURL *)sourceURL toParentURL:(NSURL *)destinationParentURL name:(NSString *)name success:(void (^)(GDURLMetadata *metadata))success failure:(void (^)(NSError *))failure;
- (void)moveFileAtURL:(NSURL *)sourceURL toParentURL:(NSURL *)destinationParentURL name:(NSString *)name success:(void (^)(GDURLMetadata *metadata))success failure:(void (^)(NSError *))failure;

- (NSOperation *)downloadURL:(NSURL *)url intoFileURL:(NSURL *)localURL fileVersion:(NSString *)fileVersionIdentifier
                    progress:(void (^)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                     success:(void (^)(NSURL *localURL, GDURLMetadata *metadata))success
                     failure:(void (^)(NSError *error))failure;

- (GDURLMetadata *)clientMetadataWithCachedMetadata:(id <GDURLMetadata>)urlMetadata parentURL:(NSURL *)url;
- (NSArray *)clientMetadataArrayWithCachedMetadataArray:(NSArray *)metadataArray parentURL:(NSURL *)url cache:(id <GDMetadataCache>)cacheOrNil;

- (NSString *)filenameAvoidingConflictsWithExistingContents:(NSArray *)contents preferredFilename:(NSString *)preferredFilename;

- (NSURL *)cacheURLForURL:(NSURL *)canonicalURL versionIdentifier:(NSString *)versionIdentifier cachedMetadata:(GDURLMetadata *__autoreleasing *)cachedMetadata;

// Subclasses may override
- (NSString *)normalisedPathForPath:(NSString *)path;
- (NSURL *)canonicalURLForURL:(NSURL *)url;
- (NSURL *)_canonicalURLForURL:(NSURL *)url;
- (NSString *)userDescription;
- (NSString *)detailDescription;

- (void)addMetadata:(id)metadata parentURL:(NSURL *)parentURL toCache:(id <GDMetadataCache>)cache
       continuation:(void (^)(GDURLMetadata *metadata, NSArray *metadataContents))continuation;

@end
