//
//  GDFileManager.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 10/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDMetadataCache.h"
#import "GDURLMetadata.h"

#import "GDFileManagerConstants.h"

#import "GDFileManagerDownloadOperation.h"

extern NSString *const GDFileManagerErrorDomain;

@class GDFileServiceManager;
@class GDFileManagerAlias;
@class GDFileServiceSession;

@interface GDFileManager : NSObject

+ (GDFileManager *)sharedManager;

+ (void)enqueueLowPriorityFileManagerOperation:(NSOperation *)operation;
- (void)enqueueLowPriorityFileManagerOperation:(NSOperation *)operation;


- (id)initWithFileServiceManager:(GDFileServiceManager *)fileServiceManager;

- (BOOL)handleOpenURL:(NSURL *)url;

- (NSURL *)uniqueRootURLForURLScheme:(NSString *)scheme error:(NSError *__autoreleasing *)error;

- (void)getContentsOfDirectoryAtURL:(NSURL *)url
                            success:(void (^)(NSArray *contents))success
                            failure:(void (^)(NSError *error))failure;

- (void)getContentsOfDirectoryAtURL:(NSURL *)url
                        cachePolicy:(GDFileManagerCachePolicy)cachePolicy
                            success:(void (^)(NSArray *contents))success
                            failure:(void (^)(NSError *error))failure;

- (void)getMetadataForURL:(NSURL *)url
                  success:(void (^)(GDURLMetadata *metadata))success
                  failure:(void (^)(NSError *error))failure;

- (void)getMetadataForURL:(NSURL *)url
              cachePolicy:(GDFileManagerCachePolicy)cachePolicy
                  success:(void (^)(GDURLMetadata *))success
                  failure:(void (^)(NSError *))failure;

- (void)getLatestVersionIdentifierForURL:(NSURL *)url
                                 success:(void (^)(NSString *versionIdentifier))success
                                 failure:(void (^)(NSError *error))failure;

- (void)getLatestVersionIdentifierForURL:(NSURL *)url
                             cachePolicy:(GDFileManagerCachePolicy)cachePolicy
                                 success:(void (^)(NSString *versionIdentifier))success
                                 failure:(void (^)(NSError *error))failure;

- (void)deleteURL:(NSURL *)url success:(void (^)())success failure:(void (^)(NSError *error))failure;

- (void)copyFileAtURL:(NSURL *)sourceURL toParentURL:(NSURL *)destinationParentURL name:(NSString *)name success:(void (^)(GDURLMetadata *metadata))success failure:(void (^)(NSError *))failure;
- (void)moveFileAtURL:(NSURL *)sourceURL toParentURL:(NSURL *)destinationParentURL name:(NSString *)name success:(void (^)(GDURLMetadata *metadata))success failure:(void (^)(NSError *))failure;

- (void)findItemsMatchingPath:(NSString *)path relativeToURL:(NSURL *)baseURL
                      success:(void (^)(NSArray *matchingMetadata))success
                      failure:(void (^)(NSError *error))failure;


- (void)createAliasForURL:(NSURL *)url
                  success:(void (^)(GDFileManagerAlias *alias))success
                  failure:(void (^)(NSError *error))failure;

- (void)resolveAlias:(GDFileManagerAlias *)alias
             success:(void (^)(GDURLMetadata *metadata, GDFileManagerAlias *updatedAlias))success
             failure:(void (^)(NSError *error))failure;

- (GDFileManagerDownloadOperation *)downloadOperationFromSourceURL:(NSURL *)url toLocalFileURL:(NSURL *)localURL
                                                           success:(void (^)(NSURL *localURL, GDURLMetadata *metadata))success
                                                           failure:(void (^)(NSError *error))failure;

- (void)enqueueFileManagerOperation:(NSOperation *)operation;

- (void)resetSessionCache;

- (NSString *)sessionNameForURL:(NSURL *)url;
- (GDFileServiceSession *)fileServiceSessionForURL:(NSURL *)url;

// by default all GDFileManager instances except the sharedManager come with GDRetainingMetadataCache instances configured as the session cache.
@property (nonatomic, strong) id <GDMetadataCache> sessionCache;
@property (nonatomic, readonly, strong) GDFileServiceManager *fileServiceManager;
@property (nonatomic) GDFileManagerCachePolicy defaultCachePolicy;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;

@end
