//
//  GDGoogleDriveFileServiceSession.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 29/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDGoogleDriveFileServiceSession.h"
#import "GDGoogleDriveFileService.h"
#import "GDGoogleDriveURLMetadata.h"

#import "GDURLMetadata_Private.h"

#import "GDDispatchUtilities.h"

@implementation GDGoogleDriveFileServiceSession

@dynamic client;

- (id)initWithFileService:(GDFileService *)fileService client:(GDHTTPClient *)client
{
    if (([super initWithFileService:fileService client:client])) {
        [(GDGoogleDriveClient *)client setDefaultMetadataFields:@"id,etag,title,mimeType,md5Checksum,fileSize,headRevisionId,editable,parents,thumbnailLink,imageMediaMetadata,downloadUrl,exportLinks"];
    }
    
    return self;
}

- (void)validateAccessWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure
{
    [self.client getAccountInfoWithSuccess:^(__unused GDGoogleDriveAccountInfo *accountInfo) {
        if (success) {
            success();
        }
    } failure:failure];
}

- (void)getMetadataForURL:(NSURL *)url metadataCache:(id <GDMetadataCache>)metadataCache cachedMetadata:(id<GDURLMetadata>)cachedMetadata
                  success:(void (^)(GDURLMetadata *metadata))success failure:(void (^)(NSError *error))failure
{
    NSString *fileID = [self fileIDFromURL:url];
    NSURL *canonicalURL = [self canonicalURLForURL:url];
    if (!cachedMetadata)
        cachedMetadata = [metadataCache metadataForURL:canonicalURL];
    
    [self.client getMetadataForFileID:fileID etag:[(GDGoogleDriveURLMetadata *)cachedMetadata etag]
                              success:^(GDGoogleDriveMetadata *metadata) {
                                  GDURLMetadata *urlMetadata = nil;
                                  if (!metadata) {
                                      urlMetadata = [[GDURLMetadata alloc] initWithURLMetadata:cachedMetadata clientURL:url canonicalURL:canonicalURL];
                                  } else {
                                      urlMetadata = [self clientMetadataForGoogleDriveMetadata:metadata clientURL:url];
                                  }
                                  [metadataCache setMetadata:urlMetadata forURL:urlMetadata.canonicalURL];
                                  if (success) success(urlMetadata);
                              } failure:failure];
}

- (void)getContentsOfDirectoryAtURL:(NSURL *)url metadataCache:(id<GDMetadataCache>)metadataCache
                     cachedMetadata:(id<GDURLMetadata>)__unused cachedMetadata cachedContents:(NSArray *)__unused contents
                            success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    NSString *fileID = [self fileIDFromURL:url];
    
    [self.client getContentsOfFileID:fileID
                             success:^(NSArray *contents, __unused NSString *etag) {
                                 return [self addMetadata:contents parentURL:url toCache:metadataCache
                                             continuation:^(__unused GDURLMetadata *metadata, NSArray *metadataContents) {
                                                 if (success) success(metadataContents);
                                             }];
                             } failure:failure];
}

- (void)deleteURL:(NSURL *)url success:(void (^)())success failure:(void (^)(NSError *))failure
{
    NSString *fileID = [self fileIDFromURL:url];
    
    [self.client trashFileID:fileID
                     success:^(__unused GDGoogleDriveMetadata *metadata) {
                         if (success) success();
                     } failure:failure];
}

- (void)copyFileAtURL:(NSURL *)sourceURL toParentURL:(NSURL *)destinationParentURL name:(NSString *)name success:(void (^)(GDURLMetadata *))success failure:(void (^)(NSError *))failure
{
    NSString *sourceFileID = [self fileIDFromURL:sourceURL];
    NSString *destinationFolderID = [self fileIDFromURL:destinationParentURL];
    
    [self.client copyFileID:sourceFileID toParentIDs:@[destinationFolderID] name:name success:^(GDGoogleDriveMetadata *metadata) {
        if (success) success([self clientMetadataForGoogleDriveMetadata:metadata parentURL:destinationParentURL]);
    } failure:failure];
}

- (void)moveFileAtURL:(NSURL *)sourceURL toParentURL:(NSURL *)destinationParentURL name:(NSString *)name success:(void (^)(GDURLMetadata *))success failure:(void (^)(NSError *))failure
{
    NSString *sourceFileID = [self fileIDFromURL:sourceURL];
    NSString *destinationFolderID = [self fileIDFromURL:destinationParentURL];
    
    [self.client moveFileID:sourceFileID toParentIDs:@[destinationFolderID] name:name success:^(GDGoogleDriveMetadata *metadata) {
        if (success) success([self clientMetadataForGoogleDriveMetadata:metadata parentURL:destinationParentURL]);
    } failure:failure];
}

- (NSOperation *)downloadURL:(NSURL *)url intoFileURL:(NSURL *)localURL fileVersion:(NSString *)__unused fileVersionIdentifier
                    progress:(void (^)(NSInteger, NSInteger, NSInteger))progress
                     success:(void (^)(NSURL *localURL, GDURLMetadata *metadata))success failure:(void (^)(NSError *))failure
{
    NSString *fileID = [self fileIDFromURL:url];
    
    return [self.client downloadFileID:fileID intoPath:[localURL path]
                              progress:progress
                               success:^(NSString *localPath, GDGoogleDriveMetadata *metadata) {
                                   GDURLMetadata *urlMetadata = [self clientMetadataForGoogleDriveMetadata:metadata clientURL:url];
                                   if (success) success([NSURL fileURLWithPath:localPath], urlMetadata);
                               } failure:failure];

}

#pragma mark - URL / path support

- (NSString *)fileIDFromURL:(NSURL *)canonicalURL
{
    NSString *lastPathComponent = [canonicalURL lastPathComponent];
    if ([lastPathComponent isEqualToString:@"/"])
        return @"root";
    return lastPathComponent;
}

- (NSURL *)clientURLByAppendingFileID:(NSString *)fileID toClientURL:(NSURL *)parentURL
{
    return [parentURL URLByAppendingPathComponent:fileID];
}

- (NSURL *)_canonicalURLForURL:(NSURL *)url
{
    if ([[url lastPathComponent] isEqualToString:@"/"])
        return self.baseURL;
    return [self.baseURL URLByAppendingPathComponent:[url lastPathComponent]];
}

- (GDURLMetadata *)clientMetadataForGoogleDriveMetadata:(GDGoogleDriveMetadata *)metadata parentURL:(NSURL *)parentURL
{
    return [self clientMetadataForGoogleDriveMetadata:metadata parentURL:parentURL clientURL:nil];
}

- (GDURLMetadata *)clientMetadataForGoogleDriveMetadata:(GDGoogleDriveMetadata *)metadata clientURL:(NSURL *)clientURL
{
    return [self clientMetadataForGoogleDriveMetadata:metadata parentURL:nil clientURL:clientURL];
}

- (GDURLMetadata *)clientMetadataForGoogleDriveMetadata:(GDGoogleDriveMetadata *)metadata parentURL:(NSURL *)parentURL clientURL:(NSURL *)clientURL
{
    if (!parentURL && !clientURL) return nil;
    if (!clientURL)
        clientURL = [self clientURLByAppendingFileID:metadata.identifier toClientURL:parentURL];
    return [[GDURLMetadata alloc] initWithURLMetadata:[[GDGoogleDriveURLMetadata alloc] initWithGoogleDriveMetadata:metadata]
                                            clientURL:clientURL
                                         canonicalURL:[self canonicalURLForURL:clientURL]];
}

- (GDURLMetadata *)clientMetadataWithCachedMetadata:(id<GDURLMetadata>)urlMetadata parentURL:(NSURL *)url
{
    NSURL *clientURL = [self clientURLByAppendingFileID:[(GDGoogleDriveURLMetadata *)urlMetadata fileID] toClientURL:url];
    
    return [[GDURLMetadata alloc] initWithURLMetadata:urlMetadata
                                            clientURL:clientURL
                                         canonicalURL:[self canonicalURLForURL:clientURL]];
}

#pragma mark - Support

- (void)addMetadata:(NSArray *)metadataArray parentURL:(NSURL *)parentURL toCache:(id<GDMetadataCache>)cache continuation:(void (^)(GDURLMetadata *, NSArray *))continuation
{
    NSMutableArray *childMetadataArray = [NSMutableArray arrayWithCapacity:[metadataArray count]];
    NSMutableDictionary *keyedChildMetadata = [NSMutableDictionary dictionaryWithCapacity:[metadataArray count]];
    
    for (GDGoogleDriveMetadata *metadata in metadataArray) {
        GDURLMetadata *urlMetadata = [self clientMetadataForGoogleDriveMetadata:metadata parentURL:parentURL];
        if (urlMetadata) {
            NSURL *canonicalURL = urlMetadata.canonicalURL;
            [childMetadataArray addObject:urlMetadata];
            keyedChildMetadata[canonicalURL] = urlMetadata;
        }
    }
    [cache setDirectoryContents:keyedChildMetadata forURL:[self canonicalURLForURL:parentURL]];
    
    return continuation(nil, [childMetadataArray copy]);
}


@end
