//
//  GDClient.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDHTTPClient.h"
#import "GDClientManager.h"
#import "GDClientCredential.h"
#import "GDAccessTokenClientCredential.h"

#import "GDHTTPOperation.h"

@interface GDHTTPClient ()

@property (nonatomic, readwrite) dispatch_queue_t isolationQueue;
@property (nonatomic, readwrite) dispatch_queue_t workQueue;

@end

NSString *const GDHTTPClientErrorDetailsKey = @"GDHTTPClientErrorDetails";

BOOL GDIsErrorPermanentlyFatal(NSError *error)
{
    // Code based on GTMHTTPFetcher, which is under the Apache license
    
    static dispatch_once_t onceToken;
    static NSArray *retryErrors = nil;
    dispatch_once(&onceToken, ^{
        retryErrors = @[
                        [NSError errorWithDomain:GDHTTPStatusErrorDomain code:408 userInfo:nil], // Request timeout
                        [NSError errorWithDomain:GDHTTPStatusErrorDomain code:503 userInfo:nil], // Service unavailable
                        [NSError errorWithDomain:GDHTTPStatusErrorDomain code:504 userInfo:nil], // Request timeout
                        [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil],
                        [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNetworkConnectionLost userInfo:nil],
                        [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotFindHost userInfo:nil]
                        ];
    });
    
    for (NSError *retryError in retryErrors) {
        if ([retryError.domain isEqualToString:error.domain]
            && retryError.code == error.code)
            return NO;
    }
    
    return YES;
}


@implementation GDHTTPClient

@synthesize available;

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    if (self.isolationQueue) {
        dispatch_release(self.isolationQueue);
        self.isolationQueue = NULL;
    }
    if (self.workQueue) {
        dispatch_release(self.workQueue);
        self.workQueue = NULL;
    }
}
#endif

- (id)initWithBaseURL:(NSURL *)url
{
    return [self initWithClientManager:nil credential:nil baseURL:url];
}

- (id)initWithClientManager:(GDClientManager *)clientManager
{
    return [self initWithClientManager:clientManager userID:nil];
}

- (id)initWithClientManager:(GDClientManager *)clientManager userID:(NSString *)userID
{
    GDClientCredential *credential = [clientManager credentialForUserID:userID];
    
    return [self initWithClientManager:clientManager credential:credential];
}

- (id)initWithClientManager:(GDClientManager *)clientManager credential:(GDClientCredential *)credential
{
    return [self initWithClientManager:clientManager credential:credential baseURL:nil];
}

- (id)initWithClientManager:(GDClientManager *)clientManager credential:(GDClientCredential *)credential baseURL:(NSURL *)baseURL
{
    if (!baseURL) return nil;
    
    if ((self = [super initWithBaseURL:baseURL])){
        _clientManager = clientManager;
        self.credential = credential;
        self.requestsIgnoreCacheByDefault = YES;
        
        NSString *label = [NSString stringWithFormat:@"%@.isolation.%p", [self class], self];
        self.isolationQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
        
        label = [NSString stringWithFormat:@"%@.work.%p", [self class], self];
        self.workQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

#pragma mark - 

- (NSString *)userID
{
    return self.credential.userID;
}

- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation
{
    if (!operation) return;
    
//    NSLog(@"Request: %@; %@", [operation request], [[operation request] allHTTPHeaderFields]);
    
    [super enqueueHTTPRequestOperation:operation];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    
    if (self.requestsIgnoreCacheByDefault)
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    return request;
}

// FIXME: I need something equivalent to a bookmark to be able to handle files being renamed.
// FIXME: I also need to be able to handle JSON responses as errors to download operations when an AFJSONRequestOperation would otherwise be inappropriate.
// This is not needed by Google Drive, but might be needed by Dropbox.
// This is needed by Dropbox and Google Drive.

- (NSOperation *)enqueueOperationWithURLRequest:(NSMutableURLRequest *)urlRequest
                         requiresAuthentication:(BOOL)requiresAuthentication
                                        success:(void (^)(AFHTTPRequestOperation *, id))success
                                        failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [self enqueueOperationWithURLRequest:urlRequest requiresAuthentication:requiresAuthentication
                               shouldRetryBlock:NULL
                                        success:success failure:failure
                        configureOperationBlock:NULL];
}

- (NSOperation *)enqueueOperationWithURLRequest:(NSMutableURLRequest *)urlRequest
                         requiresAuthentication:(BOOL)requiresAuthentication
                               shouldRetryBlock:(BOOL (^)(NSError *error))shouldRetryBlock
                                        success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
                        configureOperationBlock:(void (^)(AFHTTPRequestOperation *))configureOperationBlock
{
    GDHTTPOperation *parentOperation = [[GDHTTPOperation alloc] initWithClient:self urlRequest:urlRequest success:success failure:failure];
    parentOperation.shouldRetryAfterError = shouldRetryBlock;
    parentOperation.requiresAuthentication = requiresAuthentication;
    
    if (self.requestsIgnoreCacheByDefault) {
        parentOperation.configureOperationBlock = ^(AFHTTPRequestOperation *requestOperation) {
            [requestOperation setCacheResponseBlock:^NSCachedURLResponse *(__unused NSURLConnection *connection, __unused NSCachedURLResponse *cachedResponse) {
                return nil;
            }];
            if (configureOperationBlock)
                configureOperationBlock(requestOperation);
        };
    } else {
        parentOperation.configureOperationBlock = configureOperationBlock;
    }
    
    [parentOperation start];
    
    return parentOperation;
}

- (void)getAccessTokenWithSuccess:(void (^)(GDAccessTokenClientCredential *credential))__unused success failure:(void (^)(NSError *error))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)authorizeRequest:(NSMutableURLRequest *)__unused urlRequest
{
    return YES;
}

- (BOOL)isAuthenticationFailureError:(NSError *)__unused error
{
    return NO;
}

- (NSError *)httpErrorWithErrorDomain:(NSString *)domain fromAFNetworkingError:(NSError *)error
{
    return [self httpErrorWithErrorDomain:domain fromAFNetworkingError:error errorDetails:nil];
}


- (NSError *)httpErrorWithErrorDomain:(NSString *)domain fromAFNetworkingError:(NSError *)error errorDetails:(id)errorDetails
{
    NSError *httpError = nil;
    if ([[error domain] isEqualToString:AFNetworkingErrorDomain] && [error code] == NSURLErrorBadServerResponse) {
        NSURLResponse *response = [[error userInfo] objectForKey:@"AFNetworkingOperationFailingURLResponseErrorKey"];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSMutableDictionary *userInfo = [NSMutableDictionary new];
            userInfo[NSUnderlyingErrorKey] = error;
            userInfo[NSURLErrorFailingURLErrorKey] = [response URL];
            if (errorDetails) {
                userInfo[GDHTTPClientErrorDetailsKey] = errorDetails;
            }
            
            httpError = [NSError errorWithDomain:domain
                                            code:[(NSHTTPURLResponse *)response statusCode]
                                        userInfo:errorDetails];
        }
    }
    return httpError;
}


- (GDAPIToken *)apiToken
{
    return self.credential.apiToken;
}


@end
