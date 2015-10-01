//
//  GDAccessTokenClientCredential.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 4/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDAccessTokenClientCredential.h"
#import "GDHTTPClient.h"

@interface GDAccessTokenClientCredential ()

@property (nonatomic) dispatch_queue_t private_queue;
@property (nonatomic, strong) GDAccessTokenClientCredential *refreshedCredential;

@end

@implementation GDAccessTokenClientCredential

@dynamic accessTokenExpirationDate; // must be provided by subclass

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    if (self.private_queue) {
        dispatch_release(self.private_queue);
        self.private_queue = NULL;
    }
}
#endif

- (id)initWithUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken
{
    if ((self = [super initWithUserID:userID apiToken:apiToken])) {
        [self _commonInitGDAccessTokenClientCredential];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self _commonInitGDAccessTokenClientCredential];
    }
    
    return self;
}

- (void)_commonInitGDAccessTokenClientCredential
{
    self.private_queue = dispatch_queue_create("me.grahamdennis.GDClientCredential", DISPATCH_QUEUE_SERIAL);
}

- (BOOL)isAccessTokenValid
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)getRenewedAccessTokenUsingClient:(GDHTTPClient *)client success:(void (^)(GDClientCredential *, BOOL))success failure:(void (^)(NSError *))failure
{
    if ([self isAccessTokenValid]) {
        if (success) success(self, NO);
        return;
    }
    if (self.refreshedCredential) {
        return [self.refreshedCredential getRenewedAccessTokenUsingClient:client success:success failure:failure];
    }
    
    dispatch_async(self.private_queue, ^{
        // When we get to the start of the queue, we may now have a refreshedCredential
        if (self.refreshedCredential) {
            return [self.refreshedCredential getRenewedAccessTokenUsingClient:client success:success failure:failure];
        }
        
        // We don't have a refreshedCredential, so we need to generate one.  To make sure no-one else tries to do this while we are, we suspend the current queue.
        dispatch_suspend(self.private_queue);
        
        [client getAccessTokenWithSuccess:^(GDAccessTokenClientCredential *credential) {
            self.refreshedCredential = credential;
            
            dispatch_resume(self.private_queue);
            
            if (success) {
                success(credential, YES);
            }
        } failure:^(NSError *error) {
            dispatch_resume(self.private_queue);
            if (failure) failure(error);
        }];
    });
}

- (NSComparisonResult)compare:(GDAccessTokenClientCredential *)otherCredential
{
    return [self.accessTokenExpirationDate compare:otherCredential.accessTokenExpirationDate];
}

@end
