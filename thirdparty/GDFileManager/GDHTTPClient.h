//
//  GDClient.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <thirdparty/AFNetworking/AFNetworking.h>

#import "GDClient.h"

@class GDAPIToken;
@class GDAccessTokenClientCredential;

extern NSString *const GDHTTPClientErrorDetailsKey;
extern BOOL GDIsErrorPermanentlyFatal(NSError *error);

@interface GDHTTPClient : AFHTTPClient <GDClient>

- (id)initWithClientManager:(GDClientManager *)clientManager;
- (id)initWithClientManager:(GDClientManager *)clientManager userID:(NSString *)userID;
- (id)initWithClientManager:(GDClientManager *)clientManager credential:(GDClientCredential *)credential;

// Designated initializer
- (id)initWithClientManager:(GDClientManager *)clientManager credential:(GDClientCredential *)credential baseURL:(NSURL *)baseURL;

- (NSOperation *)enqueueOperationWithURLRequest:(NSMutableURLRequest *)urlRequest
                         requiresAuthentication:(BOOL)requiresAuthentication
                                        success:(void (^)(AFHTTPRequestOperation *, id))success
                                        failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

- (NSOperation *)enqueueOperationWithURLRequest:(NSMutableURLRequest *)urlRequest
                         requiresAuthentication:(BOOL)requiresAuthentication
                               shouldRetryBlock:(BOOL (^)(NSError *error))shouldRetryBlock
                                        success:(void (^)(AFHTTPRequestOperation *, id))success
                                        failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
                        configureOperationBlock:(void (^)(AFHTTPRequestOperation *))configureOperationBlock;


- (NSError *)httpErrorWithErrorDomain:(NSString *)domain fromAFNetworkingError:(NSError *)error;
- (NSError *)httpErrorWithErrorDomain:(NSString *)domain fromAFNetworkingError:(NSError *)error errorDetails:(id)errorDetails;

@property (nonatomic, readonly, strong) GDClientManager *clientManager;
@property (nonatomic, readonly, copy) NSString *userID;
@property (atomic, strong) GDClientCredential *credential;
@property (nonatomic, strong, readonly) GDAPIToken *apiToken;
@property (nonatomic) BOOL requestsIgnoreCacheByDefault;

@property (nonatomic, readonly) dispatch_queue_t isolationQueue;
@property (nonatomic, readonly) dispatch_queue_t workQueue;

// Subclasses to override
- (void)getAccessTokenWithSuccess:(void (^)(GDAccessTokenClientCredential *credential))success failure:(void (^)(NSError *error))failure;

- (BOOL)authorizeRequest:(NSMutableURLRequest *)urlRequest;
- (BOOL)isAuthenticationFailureError:(NSError *)error;

@end
