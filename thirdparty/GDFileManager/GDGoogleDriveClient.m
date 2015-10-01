//
//  GDGoogleDriveClient.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 24/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDGoogleDriveClient.h"
#import "GDGoogleDriveClientManager.h"
#import "GDGoogleDriveChange.h"

#import "AFJSONRequestOperation.h"

#import "GDOAuth2Credential.h"
#import "GDHTTPOperation.h"

@implementation GDGoogleDriveClient

@dynamic credential, apiToken;

- (id)initWithClientManager:(GDClientManager *)clientManager credential:(GDOAuth2Credential *)credential baseURL:(NSURL *)baseURL
{
    if (!baseURL)
        baseURL = [NSURL URLWithString:@"https://www.googleapis.com/drive/v2/"];
    
    if ((self = [super initWithClientManager:clientManager credential:credential baseURL:baseURL])) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"text/javascript; text/json; application/json"];
        
        // This is needed to make Google Drive send gzip-encoded responses
        NSString *defaultUserAgentHeader = [self defaultValueForHeader:@"User-Agent"];
        NSString *gzipUserAgent = [defaultUserAgentHeader stringByAppendingString:@" (gzip)"];
        [self setDefaultHeader:@"User-Agent" value:gzipUserAgent];
        [self setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
    }
    
    return self;
}

- (BOOL)isAvailable
{
    return true;
}

#pragma mark - HTTP methods

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    // We need to do this to ensure that PUT/POST URL parameters are encoded in the URL, not in the HTTP body.
    NSMutableURLRequest *request = [super requestWithMethod:@"GET" path:path parameters:parameters];
    
    [request setHTTPMethod:method];
    
    return request;
}


- (NSOperation *)enqueueOperationWithMethod:(NSString *)method path:(NSString *)path urlParameters:(NSDictionary *)urlParameters etag:(NSString *)etag
                                    success:(void (^)(id response))success
                                    failure:(void (^)(NSError *error))failure
{
    return [self enqueueOperationWithMethod:method path:path urlParameters:urlParameters etag:etag
                        requiresAccessToken:YES
                                    success:success failure:failure];
}

- (BOOL)authorizeRequest:(NSMutableURLRequest *)urlRequest
{
    if ([self.credential isAccessTokenValid]) {
        NSString *authorizationHeader = [NSString stringWithFormat:@"Bearer %@", self.credential.oauthCredential.accessToken];
        [urlRequest setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
        return YES;
    }
    return NO;
}

- (BOOL)isAuthenticationFailureError:(NSError *)error
{
    return [[error domain] isEqualToString:GDHTTPStatusErrorDomain] && [error code] == 401;
}


- (NSOperation *)enqueueOperationWithMethod:(NSString *)method path:(NSString *)path urlParameters:(NSDictionary *)urlParameters etag:(NSString *)etag
               requiresAccessToken:(BOOL)requiresAccessToken
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError *error))failure
{
    if (!urlParameters[@"prettyPrint"]) {
        NSMutableDictionary *mutableURLParameters = [NSMutableDictionary dictionaryWithDictionary:urlParameters];
        mutableURLParameters[@"prettyPrint"] = @"false";
        urlParameters = [mutableURLParameters copy];
    }
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:urlParameters];

    if (etag) {
        [request setValue:etag forHTTPHeaderField:@"If-None-Match"];
    }
    
    return [self enqueueOperationWithURLRequest:request
                         requiresAuthentication:requiresAccessToken
                                        success:^(__unused AFHTTPRequestOperation *requestOperation, id responseObject) {
                                            if (success) success(responseObject);
                                        }
                                        failure:^(__unused AFHTTPRequestOperation *requestOperation, NSError *error) {
                                            if (etag && [error code] == 304 && [[error domain] isEqualToString:GDHTTPStatusErrorDomain]) {
                                                // not-modified
                                                if (success) success(nil);
                                            } else {
                                                if (failure) failure(error);
                                            }
                                        }];
}

- (NSOperation *)enqueueOperationWithURLRequest:(NSMutableURLRequest *)urlRequest
                         requiresAuthentication:(BOOL)requiresAuthentication
                               shouldRetryBlock:(BOOL (^)(NSError *))shouldRetryBlock
                                        success:(void (^)(AFHTTPRequestOperation *, id))success
                                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *))failure
                        configureOperationBlock:(void (^)(AFHTTPRequestOperation *))configureOperationBlock
{
    return [super enqueueOperationWithURLRequest:urlRequest
                          requiresAuthentication:requiresAuthentication
                                shouldRetryBlock:shouldRetryBlock
                                         success:success
                                         failure:failure
                         configureOperationBlock:^(AFHTTPRequestOperation *requestOperation) {
                             [requestOperation setCacheResponseBlock:^NSCachedURLResponse *(__unused NSURLConnection *connection, __unused NSCachedURLResponse *cachedResponse) {
                                 return nil;
                             }];
                             if (configureOperationBlock)
                                 configureOperationBlock(requestOperation);
                         }];
}

#pragma mark - Access token

- (void)getAccessTokenWithSuccess:(void (^)(GDOAuth2Credential *))success failure:(void (^)(NSError *))failure
{
    AFOAuth2Client *oauthClient = [AFOAuth2Client clientWithBaseURL:[NSURL URLWithString:@"https://accounts.google.com/o/oauth2/"]
                                                           clientID:self.apiToken.key secret:self.apiToken.secret];
    
    [oauthClient authenticateUsingOAuthWithPath:@"token"
                                   refreshToken:self.credential.oauthCredential.refreshToken
                                        success:^(AFOAuthCredential *credential)
    {
        GDOAuth2Credential *gdCredential = [[GDOAuth2Credential alloc] initWithOAuthCredential:credential
                                                                                        userID:self.credential.userID
                                                                                      apiToken:self.apiToken];
        if (success) success(gdCredential);
    } failure:^(NSError *error) {
        NSError *httpError = [self httpErrorWithErrorDomain:GDHTTPStatusErrorDomain fromAFNetworkingError:error];
        if (failure) failure(httpError ?: error);
    }];

}

#pragma mark - Account operations

- (void)getAccountInfoWithSuccess:(void (^)(GDGoogleDriveAccountInfo *))success failure:(void (^)(NSError *))failure
{
    [self enqueueOperationWithMethod:@"GET"
                                path:@"/oauth2/v1/userinfo"
                       urlParameters:nil
                                etag:nil
                             success:^(id response) {
                                 if (![response isKindOfClass:[NSDictionary class]]) {
                                     if (failure) failure(nil);
                                     return;
                                 }
                                 GDGoogleDriveAccountInfo *accountInfo = [[GDGoogleDriveAccountInfo alloc] initWithDictionary:response];
                                 if (success) {
                                     success(accountInfo);
                                 }
                                 
                             } failure:^(NSError *error) {
                                 NSLog(@"error: %@", error);
                                 if (failure) failure(error);
                             }];
}

#pragma mark - Metadata operations

- (NSString *)groupedMetadataFieldsSelectorForSelector:(NSString *)fieldsSelector
{
    if (!fieldsSelector) return @"";
    else return [NSString stringWithFormat:@"(%@)", fieldsSelector];
}

- (void)getMetadataForFileID:(NSString *)fileID success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure
{
    [self getMetadataForFileID:fileID etag:nil success:success failure:failure];
}

- (void)getMetadataForFileID:(NSString *)fileID etag:(NSString *)etag
                     success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure
{
    [self getMetadataForFileID:fileID
                          etag:etag
                metadataFields:self.defaultMetadataFields
                       success:success failure:failure];
}


- (void)getMetadataForFileID:(NSString *)fileID etag:(NSString *)etag metadataFields:(NSString *)metadataFields
                     success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(fileID);
    
    NSString *path = [@"files/" stringByAppendingString:fileID];
    
    NSMutableDictionary *urlParameters = nil;
    if (metadataFields) {
        urlParameters = [NSMutableDictionary new];
        urlParameters[@"fields"] = metadataFields;
    }
    
    [self enqueueOperationWithMethod:@"GET"
                                path:path
                       urlParameters:urlParameters
                                etag:etag
                             success:^(id response) {
                                 GDGoogleDriveMetadata *metadata = nil;
                                 if (response) {
                                     NSParameterAssert([response isKindOfClass:[NSDictionary class]]);
                                     metadata = [[GDGoogleDriveMetadata alloc] initWithDictionary:response];
                                 }
                                 if (success) success(metadata);
                             } failure:failure];
}

- (void)getContentsOfFileID:(NSString *)fileID success:(void (^)(NSArray *contents, NSString *etag))success failure:(void (^)(NSError *error))failure
{
    return [self getContentsOfFileID:fileID etag:nil success:success failure:failure];
}

- (void)getContentsOfFileID:(NSString *)fileID etag:(NSString *)etag success:(void (^)(NSArray *, NSString *))success failure:(void (^)(NSError *))failure
{
    return [self getContentsOfFileID:fileID etag:etag metadataFields:self.defaultMetadataFields success:success failure:failure];
}

- (void)getContentsOfFileID:(NSString *)fileID etag:(NSString *)etag metadataFields:(NSString *)metadataFields
                    success:(void (^)(NSArray *, NSString *))success failure:(void (^)(NSError *))failure
{
    NSString *queryString = [NSString stringWithFormat:@"'%@' in parents and trashed = false", fileID];
    return [self getFileListWithQuery:queryString etag:etag metadataFields:metadataFields success:success failure:failure];
}

- (void)getFileListWithQuery:(NSString *)query etag:(NSString *)etag metadataFields:(NSString *)metadataFields
                     success:(void (^)(NSArray *, NSString *))success failure:(void (^)(NSError *))failure
{
    NSMutableArray *resultsArray = [NSMutableArray new];
    
    return [self getFileListWithQuery:query pageToken:nil etag:etag metadataFields:metadataFields resultsArray:resultsArray
                              success:^(NSString *etag) {
                                  if (success) return success([resultsArray copy], etag);
                              } failure:failure];
}

- (void)getFileListWithQuery:(NSString *)query pageToken:(NSString *)pageToken etag:(NSString *)etag
              metadataFields:(NSString *)metadataFields resultsArray:(NSMutableArray *)resultsArray
                     success:(void (^)(NSString *etag))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *urlParameters = [NSMutableDictionary new];
    if (query)
        urlParameters[@"q"] = query;
    if (pageToken)
        urlParameters[@"pageToken"] = pageToken;
    urlParameters[@"maxResults"] = @"1000";
    urlParameters[@"fields"] = [NSString stringWithFormat:@"etag,nextPageToken,items%@", [self groupedMetadataFieldsSelectorForSelector:metadataFields]];
    
    [self enqueueOperationWithMethod:@"GET"
                                path:@"files"
                       urlParameters:urlParameters
                                etag:etag
                             success:^(id response) {
                                 if (response) {
                                     NSParameterAssert([response isKindOfClass:[NSDictionary class]]);
                                     NSDictionary *dictionary = (NSDictionary *)response;
                                     
                                     [self appendMetadataFromFileListResponse:dictionary toArray:resultsArray];
                                     NSString *rootETag = dictionary[@"etag"];
                                     
                                     NSString *nextPageToken = dictionary[@"nextPageToken"];
                                     if (nextPageToken) {
                                         [self getFileListWithQuery:query
                                                          pageToken:nextPageToken
                                                               etag:nil
                                                     metadataFields:metadataFields
                                                       resultsArray:resultsArray
                                                            success:^(__unused NSString *etag) {
                                                                if (success) success(rootETag);
                                                            } failure:failure];
                                         return;
                                     } else {
                                         if (success) success(rootETag);
                                     }
                                 }
                             } failure:failure];
    
}

- (void)appendMetadataFromFileListResponse:(NSDictionary *)responseDictionary toArray:(NSMutableArray *)array
{
    for (NSDictionary *itemMetadata in responseDictionary[@"items"]) {
        GDGoogleDriveMetadata *metadata = [[GDGoogleDriveMetadata alloc] initWithDictionary:itemMetadata];
        [array addObject:metadata];
    }
}

- (void)getRevisionHistoryForFileID:(NSString *)fileID
                            success:(void (^)(NSArray *history))success
                            failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(fileID);
    NSString *path = [NSString pathWithComponents:@[@"files", fileID, @"revisions"]];
    
    [self enqueueOperationWithMethod:@"GET"
                                path:path
                       urlParameters:nil
                                etag:nil
                             success:^(id response) {
                                 if ([response isKindOfClass:[NSDictionary class]]) {
                                     NSDictionary *responseDict = response;
                                     NSArray *rawMetadataArray = responseDict[@"items"];
                                     NSMutableArray *versionHistory = [NSMutableArray arrayWithCapacity:[rawMetadataArray count]];
                                     for (NSDictionary *rawMetadata in rawMetadataArray) {
                                         GDGoogleDriveMetadata *metadata = [[GDGoogleDriveMetadata alloc] initWithDictionary:rawMetadata];
                                         if (metadata)
                                             [versionHistory addObject:metadata];
                                     }
                                     NSArray *newestFirstVersionHistory = [[versionHistory reverseObjectEnumerator] allObjects];
                                     if (success) success(newestFirstVersionHistory);
                                 } else {
                                     if (failure) failure(nil);
                                 }
                             } failure:failure];
}

- (void)trashFileID:(NSString *)fileID success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(fileID);
    NSString *path = [NSString pathWithComponents:@[@"files", fileID, @"trash"]];
    
    NSMutableDictionary *urlParameters = [NSMutableDictionary new];
    if (self.defaultMetadataFields)
        urlParameters[@"fields"] = self.defaultMetadataFields;
    
    [self enqueueOperationWithMethod:@"POST"
                                path:path
                       urlParameters:urlParameters
                                etag:nil
                             success:^(id response) {
                                 GDGoogleDriveMetadata *metadata = nil;
                                 if (response) {
                                     NSParameterAssert([response isKindOfClass:[NSDictionary class]]);
                                     metadata = [[GDGoogleDriveMetadata alloc] initWithDictionary:response];
                                 }
                                 if (success) success(metadata);
                             } failure:failure];
}

- (void)deleteFileID:(NSString *)fileID success:(void (^)())success failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(fileID);
    NSString *path = [NSString pathWithComponents:@[@"files", fileID]];
    
    [self enqueueOperationWithMethod:@"DELETE"
                                path:path
                       urlParameters:nil
                                etag:nil
                             success:^(__unused id response) {
                                 if (success) success();
                             } failure:failure];
}

static NSString *const GDGoogleDriveCopyOperation = @"COPY";
static NSString *const GDGoogleDriveMoveOperation = @"MOVE";

- (void)copyFileID:(NSString *)fileID toParentIDs:(NSArray *)parentIDs name:(NSString *)name
           success:(void (^)(GDGoogleDriveMetadata *metadata))success failure:(void (^)(NSError *error))failure
{
    return [self copyOrMove:GDGoogleDriveCopyOperation fromFileID:fileID toParentIDs:parentIDs name:name success:success failure:failure];
}

- (void)moveFileID:(NSString *)fileID toParentIDs:(NSArray *)parentIDs name:(NSString *)name success:(void (^)(GDGoogleDriveMetadata *))success failure:(void (^)(NSError *))failure
{
    return [self copyOrMove:GDGoogleDriveMoveOperation fromFileID:fileID toParentIDs:parentIDs name:name success:success failure:failure];
}

- (void)copyOrMove:(NSString *)operation fromFileID:(NSString *)fileID toParentIDs:(NSArray *)parentIDs name:(NSString *)name success:(void (^)(GDGoogleDriveMetadata *))success failure:(void (^)(NSError *))failure
{
    NSParameterAssert(fileID);
    NSParameterAssert(parentIDs);
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:@[@"files", fileID]];
    
    if ([operation isEqualToString:GDGoogleDriveCopyOperation])
        [pathComponents addObject:@"copy"];
    NSString *path = [NSString pathWithComponents:pathComponents];
    
    NSMutableDictionary *jsonDict = [NSMutableDictionary new];
    if (parentIDs)
        jsonDict[@"parents"] = parentIDs;
    if (name)
        jsonDict[@"title"] = name;
    
    NSString *method = [operation isEqualToString:GDGoogleDriveCopyOperation] ? @"POST" : @"PATCH";
    
    NSMutableURLRequest *urlRequest = [self requestWithMethod:method path:path parameters:nil];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    if (!jsonData) {
        if (failure) failure(error);
        return;
    }
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [urlRequest setHTTPBody:jsonData];
    
    [self enqueueOperationWithURLRequest:urlRequest requiresAuthentication:YES success:^(__unused AFHTTPRequestOperation *requestOperation, id response) {
        GDGoogleDriveMetadata *metadata = nil;
        if (response) {
            NSParameterAssert([response isKindOfClass:[NSDictionary class]]);
            metadata = [[GDGoogleDriveMetadata alloc] initWithDictionary:response];
        }
        if (success) success(metadata);
    } failure:^(__unused AFHTTPRequestOperation *requestOperation, NSError *error) {
        if (failure) failure(error);
    }];
}

#pragma mark - Download

- (NSOperation *)downloadFileID:(NSString *)fileID intoPath:(NSString *)localPath
                       progress:(void (^)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                        success:(void (^)(NSString *localPath, GDGoogleDriveMetadata *metadata))success_
                        failure:(void (^)(NSError *error))failure_
{
    __block GDParentOperation *parentOperation = [GDParentOperation new];
    dispatch_block_t cleanup = ^{[parentOperation finish]; parentOperation = nil;};
    typeof(success_) success = ^(NSString *localPath, GDGoogleDriveMetadata *metadata){
        dispatch_async(parentOperation.successCallbackQueue, ^{
            if (success_) success_(localPath, metadata);
            cleanup();
        });
    };
    typeof(failure_) failure = ^(NSError *error){
        dispatch_async(parentOperation.failureCallbackQueue, ^{
            if (failure_) failure_(error);
            cleanup();
        });
    };
    
    NSString *metadataFields = self.defaultMetadataFields;
    if (metadataFields) {
        metadataFields = [metadataFields stringByAppendingString:@",downloadUrl"];
    } else {
        metadataFields = @"downloadUrl";
    }
    
    [self getMetadataForFileID:fileID etag:nil metadataFields:metadataFields
                       success:^(GDGoogleDriveMetadata *metadata) {
                           NSString *downloadURLString = [metadata downloadURLString];
                           
                           NSMutableURLRequest *urlRequest = [self requestWithMethod:@"GET" path:downloadURLString parameters:nil];
                           [urlRequest setValue:@"*/*" forHTTPHeaderField:@"Accept"];
                           
                           NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:localPath append:NO];
                           
                           [self enqueueOperationWithURLRequest:urlRequest
                                         requiresAuthentication:YES
                                               shouldRetryBlock:NULL
                                                        success:^(__unused AFHTTPRequestOperation *requestOperation, __unused id responseObject) {
                                                            success(localPath, metadata);
                                                        }
                                                        failure:^(__unused AFHTTPRequestOperation *requestOperation, NSError *error) {
                                                            failure(error);
                                                        }
                                        configureOperationBlock:^(AFHTTPRequestOperation *requestOperation) {
                                            [parentOperation addChildOperation:requestOperation];
                                            requestOperation.outputStream = outputStream;
                                            [requestOperation setDownloadProgressBlock:progress];
                                        }];
                           
                           
                       } failure:failure];
    
    [parentOperation start];
    
    return parentOperation;
}

#pragma mark - Change operations

- (void)getAllChangesWithStartChangeID:(NSString *)changeID success:(void (^)(NSArray *, NSNumber *))success failure:(void (^)(NSError *))failure
{
    [self getAllChangesWithStartChangeID:changeID metadataFields:self.defaultMetadataFields success:success failure:failure];
}

- (void)getAllChangesWithStartChangeID:(NSNumber *)changeID metadataFields:(NSString *)metadataFields
                               success:(void (^)(NSArray *changes, NSNumber *largestChangeID))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *urlParameters = @{@"startChangeId": [changeID stringValue]};
    
    [self getChangesWithURLParameters:urlParameters metadataFields:metadataFields success:success failure:failure];
}

- (void)getChangesFromLastKnownChangeID:(NSNumber *)lastKnownChangeID success:(void (^)(NSArray *, NSNumber *))success failure:(void (^)(NSError *))failure
{
    [self getChangesFromLastKnownChangeID:lastKnownChangeID metadataFields:self.defaultMetadataFields success:success failure:failure];
}

- (void)getChangesFromLastKnownChangeID:(NSNumber *)lastKnownChangeID metadataFields:(NSString *)metadataFields
                                success:(void (^)(NSArray *changes, NSNumber *largestChangeID))success failure:(void (^)(NSError *error))failure
{
    long long nextChangeId = [lastKnownChangeID longLongValue] + 1LL;
    NSDictionary *urlParameters = @{@"pageToken": [[NSNumber numberWithLongLong:nextChangeId] stringValue]};
    
    [self getChangesWithURLParameters:urlParameters metadataFields:metadataFields success:success failure:failure];
}

- (void)getChangesWithURLParameters:(NSDictionary *)urlParameters metadataFields:(NSString *)metadataFields
                            success:(void (^)(NSArray *changes, NSNumber *largestChangeID))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *mutableURLParameters = [NSMutableDictionary dictionaryWithDictionary:urlParameters];
    mutableURLParameters[@"fields"] = [NSString stringWithFormat:@"etag,nextPageToken,items%@", [self groupedMetadataFieldsSelectorForSelector:metadataFields]];
    
    NSMutableArray *results = [NSMutableArray new];
    return [self getChangesWithURLParameters:mutableURLParameters
                                resultsArray:results
                                     success:^(NSNumber *largestChangeID) {
                                         if (success) {
                                             success([results copy], largestChangeID);
                                         }
                                     } failure:failure];
}

- (void)getChangesWithURLParameters:(NSDictionary *)urlParameters resultsArray:(NSMutableArray *)resultsArray
                            success:(void (^)(NSNumber *largestChangeID))success failure:(void (^)(NSError *error))failure
{
    if (!urlParameters) {
        urlParameters = [NSDictionary new];
    }
    if (!urlParameters[@"maxResults"]) {
        NSMutableDictionary *modifiedURLParameters = [urlParameters mutableCopy];
        modifiedURLParameters[@"maxResults"] = @"1000";
        urlParameters = [modifiedURLParameters copy];
    }
    
    [self enqueueOperationWithMethod:@"GET"
                                path:@"changes"
                       urlParameters:urlParameters
                                etag:nil
                             success:^(id response) {
                                 NSParameterAssert([response isKindOfClass:[NSDictionary class]]);
                                 NSDictionary *dictionary = (NSDictionary *)response;
                                 
                                 [self appendChangesFromChangeListResponse:dictionary toArray:resultsArray];
                                 
                                 NSString *nextPageToken = dictionary[@"nextPageToken"];
                                 if (nextPageToken) {
                                     NSMutableDictionary *nextPageURLParameters = [urlParameters mutableCopy];
                                     nextPageURLParameters[@"pageToken"] = nextPageToken;
                                     [self getChangesWithURLParameters:nextPageURLParameters
                                                          resultsArray:resultsArray
                                                               success:success
                                                               failure:failure];
                                     return;
                                 } else {
                                     NSString *largestChangeIDString = dictionary[@"largestChangeId"];
                                     NSNumber *largestChangeID = [NSNumber numberWithLongLong:[largestChangeIDString longLongValue]];
                                     if (success) success(largestChangeID);
                                 }
                             } failure:failure];
}

- (void)appendChangesFromChangeListResponse:(NSDictionary *)responseDictionary toArray:(NSMutableArray *)array
{
    for (NSDictionary *changeDictionary in responseDictionary[@"items"]) {
        GDGoogleDriveChange *change = [[GDGoogleDriveChange alloc] initWithDictionary:changeDictionary];
        [array addObject:change];
    }
}



@end
