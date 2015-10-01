//
//  GDCredentialManager.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 11/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDCredentialManager.h"
#import "GDCredentialManager_Private.h"

#import "GDKeychainCredentialManager.h"

#import "GDClientCredential.h"
#import "GDAPIToken.h"

static GDCredentialManager *sharedCredentialManager;

@interface GDCredentialManager ()

@property (nonatomic, copy) NSDictionary *keyedClientCredentials;

@end

@implementation GDCredentialManager

+ (void)setSharedCredentialManager:(GDCredentialManager *)credentialManager
{
    sharedCredentialManager = credentialManager;
}

+ (GDCredentialManager *)sharedCredentialManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedCredentialManager) {
            sharedCredentialManager = [GDKeychainCredentialManager new];
        }
    });
    
    return sharedCredentialManager;
}

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    if (self.isolationQueue) {
        dispatch_release(self.isolationQueue);
        self.isolationQueue = NULL;
    }
}
#endif

- (id)init
{
    if ((self = [super init])) {
        self.isolationQueue = dispatch_queue_create("org.telegram.KeychainCredentialManager", DISPATCH_QUEUE_CONCURRENT);
        self.keyedClientCredentials = [NSDictionary new];
        
    }
    
    return self;
}

- (void)addCredential:(GDClientCredential *)credential forAccount:(NSString *)account
{
    if (!credential) return;
    if (![credential isValid]) return;
    
    [self mutateClientCredentialsForAccount:account asyncMutationBlock:^(NSMutableArray *clientCredentials) {
        [clientCredentials removeObject:credential];
        [clientCredentials insertObject:credential atIndex:0];
    }];
}

- (void)removeCredential:(GDClientCredential *)credential forAccount:(NSString *)account
{
    if (!credential) return;

    [self mutateClientCredentialsForAccount:account asyncMutationBlock:^(NSMutableArray *clientCredentials) {
        [clientCredentials removeObject:credential];
    }];
}

- (void)mutateClientCredentialsForAccount:(NSString *)account asyncMutationBlock:(void (^)(NSMutableArray *clientCredentials))mutationBlock
{
    NSParameterAssert(account);
    
    dispatch_barrier_async(self.isolationQueue, ^{
        NSMutableArray *clientCredentials = [NSMutableArray arrayWithArray:self.keyedClientCredentials[account]];
        if (!clientCredentials)
            clientCredentials = [NSMutableArray new];
        
        mutationBlock(clientCredentials);
        
        NSMutableDictionary *mutableKeyedClientCredentials = [self.keyedClientCredentials mutableCopy];
        NSArray *immutableClientCredentials = [clientCredentials copy];
        mutableKeyedClientCredentials[account] = immutableClientCredentials;
        
        self.keyedClientCredentials = [mutableKeyedClientCredentials copy];
        
        [self saveCredentials:immutableClientCredentials forAccount:account];
    });
}

- (NSArray *)clientCredentialsForAccount:(NSString *)account
{
    __block NSArray *clientCredentials = nil;
    dispatch_sync(self.isolationQueue, ^{
        clientCredentials = self.keyedClientCredentials[account];
        if (!clientCredentials) {
            clientCredentials = [self loadCredentialsForAccount:account];
            NSMutableDictionary *mutableKeyedCredentials = [self.keyedClientCredentials mutableCopy];
            mutableKeyedCredentials[account] = clientCredentials;
            self.keyedClientCredentials = [mutableKeyedCredentials copy];
        }
    });
    return clientCredentials;
}

#pragma mark - Subclasses to override

- (void)saveCredentials:(NSArray *)__unused credentials forAccount:(NSString *)__unused account
{
    [self doesNotRecognizeSelector:_cmd];
}

- (NSArray *)loadCredentialsForAccount:(NSString *)__unused account
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
