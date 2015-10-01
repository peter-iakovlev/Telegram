//
//  GDGoogleDriveClient.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 24/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDHTTPClient.h"
#import "GDGoogleDriveAccountInfo.h"
#import "GDOAuth2Credential.h"
#import "GDGoogleDriveAPIToken.h"
#import "GDGoogleDriveMetadata.h"

@interface GDGoogleDriveClient : GDHTTPClient

- (void)getAccessTokenWithSuccess:(void (^)(GDOAuth2Credential *credential))success failure:(void (^)(NSError *error))failure;

- (void)getAccountInfoWithSuccess:(void (^)(GDGoogleDriveAccountInfo *accountInfo))success failure:(void (^)(NSError *error))failure;

- (void)getMetadataForFileID:(NSString *)fileID
                     success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure;
- (void)getMetadataForFileID:(NSString *)fileID etag:(NSString *)etag
                     success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure;
- (void)getMetadataForFileID:(NSString *)fileID etag:(NSString *)etag metadataFields:(NSString *)metadataFields
                     success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure;

- (void)getContentsOfFileID:(NSString *)fileID
                    success:(void (^)(NSArray *contents, NSString *etag))success failure:(void (^)(NSError *error))failure;
- (void)getContentsOfFileID:(NSString *)fileID etag:(NSString *)etag
                    success:(void (^)(NSArray *contents, NSString *etag))success failure:(void (^)(NSError *error))failure;
- (void)getContentsOfFileID:(NSString *)fileID etag:(NSString *)etag metadataFields:(NSString *)metadataFields
                    success:(void (^)(NSArray *contents, NSString *etag))success failure:(void (^)(NSError *error))failure;

- (void)getFileListWithQuery:(NSString *)query etag:(NSString *)etag metadataFields:(NSString *)metadataFields
                     success:(void (^)(NSArray *contents, NSString *etag))success failure:(void (^)(NSError *error))failure;

- (void)getAllChangesWithStartChangeID:(NSString *)changeID
                               success:(void (^)(NSArray *changes, NSNumber *largestChangeID))success failure:(void (^)(NSError *error))failure;
- (void)getAllChangesWithStartChangeID:(NSString *)changeID metadataFields:(NSString *)metadataFields
                               success:(void (^)(NSArray *changes, NSNumber *largestChangeID))success failure:(void (^)(NSError *error))failure;

- (void)getChangesFromLastKnownChangeID:(NSNumber *)lastKnownChangeID
                                success:(void (^)(NSArray *changes, NSNumber *largestChangeID))success failure:(void (^)(NSError *error))failure;
- (void)getChangesFromLastKnownChangeID:(NSNumber *)lastKnownChangeID metadataFields:(NSString *)metadataFields
                                success:(void (^)(NSArray *changes, NSNumber *largestChangeID))success failure:(void (^)(NSError *error))failure;

- (void)getRevisionHistoryForFileID:(NSString *)fileID
                            success:(void (^)(NSArray *history))success
                            failure:(void (^)(NSError *error))failure;

- (void)trashFileID:(NSString *)fileID success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure;
- (void)deleteFileID:(NSString *)fileID success:(void (^)())success failure:(void (^)(NSError *error))failure;

- (void)copyFileID:(NSString *)fileID toParentIDs:(NSArray *)parentIDs name:(NSString *)name success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure;
- (void)moveFileID:(NSString *)fileID toParentIDs:(NSArray *)parentIDs name:(NSString *)name success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure;

- (NSOperation *)downloadFileID:(NSString *)fileID intoPath:(NSString *)localPath
                       progress:(void (^)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                        success:(void (^)(NSString *localPath, GDGoogleDriveMetadata *metadata))success
                        failure:(void (^)(NSError *error))failure;

@property (atomic, strong) GDOAuth2Credential *credential;
@property (nonatomic, strong, readonly) GDGoogleDriveAPIToken *apiToken;
@property (nonatomic, strong) NSString *defaultMetadataFields;

@end
