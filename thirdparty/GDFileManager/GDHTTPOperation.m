//
//  GDParentOperation.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 4/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDHTTPOperation.h"

#import "AFJSONRequestOperation.h"

#import "GDHTTPClient.h"
#import "GDClientManager.h"
#import "GDAccessTokenClientCredential.h"

NSString * const GDHTTPStatusErrorDomain = @"GDHTTPStatusErrorDomain";

@interface GDHTTPOperation ()

@property (nonatomic) BOOL autoRefreshAccessToken;
@property (nonatomic) BOOL forceAccessTokenRefresh;
@property (nonatomic) NSUInteger numberOfRetryAttempts;
@property (nonatomic) NSUInteger maximumNumberOfRetryAttempts;

@end

@implementation GDHTTPOperation

- (id)initWithClient:(GDHTTPClient *)client urlRequest:(NSMutableURLRequest *)urlRequest
             success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *))failure
{
    if ((self = [super init])) {
        _client = client;
        _urlRequest = urlRequest;
        
        __block typeof(self) strongSelf = self;
        dispatch_block_t cleanup = ^{[strongSelf finish]; strongSelf->_success = nil; strongSelf->_failure = nil; strongSelf->_shouldRetryAfterError = nil; strongSelf->_configureOperationBlock = nil; strongSelf = nil;};
        
        _success = ^(AFHTTPRequestOperation *operation, id responseObject){
            dispatch_async(strongSelf.successCallbackQueue, ^{
                if (success) success(operation, responseObject);
                cleanup();
            });
        };
        _failure = ^(AFHTTPRequestOperation *operation, NSError *error){
            dispatch_async(strongSelf.failureCallbackQueue, ^{
                if (failure) failure(operation, error);
                cleanup();
            });
        };
        
        self.requiresAuthentication = YES;
        self.autoRefreshAccessToken = YES;
        
        self.maximumNumberOfRetryAttempts = 5;
        self.retryOnStandardErrors = YES;
    }
    
    return self;
}

- (id)init
{
    return [self initWithClient:nil urlRequest:nil success:NULL failure:NULL];
}

- (void)main
{
    if (![self isExecuting]) {
        return self.failure(nil, GDOperationCancelledError);
    }
    
    GDHTTPClient *client = self.client;
    if (self.requiresAuthentication) {
        if (!self.forceAccessTokenRefresh && [self.client authorizeRequest:self.urlRequest]) {
            // Request is now authorized
            ;
        } else {
            if ((self.forceAccessTokenRefresh || self.autoRefreshAccessToken) && [client.credential isKindOfClass:[GDAccessTokenClientCredential class]]) {
                self.forceAccessTokenRefresh = NO;
                GDAccessTokenClientCredential *oldCredential = (GDAccessTokenClientCredential *)client.credential;
                [oldCredential getRenewedAccessTokenUsingClient:client
                                                        success:^(GDClientCredential *credential, BOOL isFreshFromRemote) {
                                                            [client.clientManager removeCredential:oldCredential];
                                                            [client.clientManager addCredential:credential];
                                                            client.credential = credential;
                                                            
                                                            self.autoRefreshAccessToken = !isFreshFromRemote;
                                                            
                                                            [self main];
                                                        } failure:^(NSError *error) {
                                                            self.failure(nil, error);
                                                        }];
                
            } else {
                self.failure(nil, nil);
            }
            return;
        }
    }
    
    AFHTTPRequestOperation *operation = nil;
    operation = [client HTTPRequestOperationWithRequest:self.urlRequest
                                                success:self.success
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        id errorDetails = nil;
        if ([operation isKindOfClass:[AFJSONRequestOperation class]]) {
            errorDetails = [(AFJSONRequestOperation *)operation responseJSON];
        }
        
        NSError *httpError = [client httpErrorWithErrorDomain:GDHTTPStatusErrorDomain fromAFNetworkingError:error errorDetails:errorDetails];
        error = httpError ?: error;
        
        if ([client.credential canBeRenewed] && [client isAuthenticationFailureError:error]) {
            self.forceAccessTokenRefresh = YES;
            self.requiresAuthentication = YES;
            
            [self main];
            
            return;
        } else if (!([[error domain] isEqualToString:NSURLErrorDomain] && [error code] == NSURLErrorCancelled)
                   && [self isRetryError:error]
                   && self.numberOfRetryAttempts < self.maximumNumberOfRetryAttempts) {
            double delayInSeconds = pow(2.0, self.numberOfRetryAttempts++) + arc4random_uniform(500)/1000.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [self main];
            });
            
            return;
        } else {
            self.failure(operation, error);
        }
    }];
    if (self.configureOperationBlock)
        self.configureOperationBlock(operation);
    
    [self addChildOperation:operation];
    
    [client enqueueHTTPRequestOperation:operation];
}

- (BOOL)isRetryError:(NSError *)error
{
    if (self.retryOnStandardErrors) {
        if (!GDIsErrorPermanentlyFatal(error))
            return YES;
    }
    
    if (self.shouldRetryAfterError) {
        return self.shouldRetryAfterError(error);
    }
    
    return NO;
}

@end
