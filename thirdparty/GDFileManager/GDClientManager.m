//
//  GDClientManager.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 23/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDClientManager.h"

#import "GDAPIToken.h"
#import "GDHTTPClient.h"
#import "GDClientCredential.h"

#import "GDDispatchUtilities.h"

#import "GDCredentialManager.h"

static NSDictionary *managerMap = nil;
static dispatch_queue_t manager_map_queue = nil;

@interface GDClientManager ()

@property (nonatomic, copy) NSArray *clientCredentials;
@property (nonatomic, readonly) dispatch_queue_t private_queue;

@end

@implementation GDClientManager

#pragma mark - Class Support methods

+ (void)initialize
{
    if (self == [GDClientManager class]) {
        managerMap = [NSDictionary new];
        manager_map_queue = dispatch_queue_create("me.grahamdennis.GDClientManager.manager_map_queue", DISPATCH_QUEUE_CONCURRENT);
    }
}

+ (Class)apiTokenClass { return nil; }

+ (Class)clientClass { return nil; }

+ (instancetype)sharedManager
{
    __block GDClientManager *clientManager = nil;
    
    dispatch_sync(manager_map_queue, ^{
        clientManager = managerMap[NSStringFromClass(self)];
    });
    if (!clientManager) {
        dispatch_barrier_sync(manager_map_queue, ^{
            if (clientManager) return;
            clientManager = [[self class] new];
            clientManager.persistenceIdentifier = NSStringFromClass([self class]);
            clientManager.defaultAPIToken = [[self apiTokenClass] sharedToken];
            [[self class] _setSharedManager:clientManager];
        });
    }

    return clientManager;
}

+ (void)setSharedManager:(GDClientManager *)manager
{
    NSParameterAssert(!manager || [manager isKindOfClass:self]);

    dispatch_barrier_async(manager_map_queue, ^{
        [self _setSharedManager:manager];
    });
}

+ (void)_setSharedManager:(GDClientManager *)manager
{
    NSString *key = NSStringFromClass(manager ? [manager class] : self);
    
    NSMutableDictionary *mutablemanagerMap = [NSMutableDictionary new];
    if (managerMap) {
        [mutablemanagerMap addEntriesFromDictionary:managerMap];
    }
    if (manager) {
        mutablemanagerMap[key] = manager;
    } else {
        GDClientManager *oldManager = mutablemanagerMap[key];
        [mutablemanagerMap removeObjectForKey:key];
        oldManager.persistenceIdentifier = nil; // Don't let it save to the keychain anymore.
    }
    managerMap = [mutablemanagerMap copy];
}

#pragma mark - Instance methods

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    if (_private_queue) {
        dispatch_release(_private_queue);
        _private_queue = NULL;
    }
}
#endif

- (id)init
{
    if ((self = [super init])) {
        Class apiTokenClass = [[self class] apiTokenClass];
        GDAPIToken *apiToken = [apiTokenClass sharedToken];
        self.defaultAPIToken = apiToken;
        self.credentialManager = [GDCredentialManager sharedCredentialManager];
        
        _private_queue = dispatch_queue_create("me.grahamdennis.GDClientManager", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

#pragma mark - Default API token

- (void)setDefaultKey:(NSString *)key secret:(NSString *)secret
{
    Class apiTokenClass = [[self class] apiTokenClass];
    GDAPIToken *apiToken = [(GDAPIToken *)[apiTokenClass alloc] initWithKey:key secret:secret];
    if (apiToken) {
        [apiTokenClass registerToken:apiToken];
    }
    self.defaultAPIToken = apiToken;
}

- (BOOL)isValid
{
    return !!self.defaultAPIToken;
}

#pragma mark - Credentials

- (NSArray *)clientCredentials
{
    if (_clientCredentials)
    {
    }
    
    return [self.credentialManager clientCredentialsForAccount:self.persistenceIdentifier];
}

- (void)addCredential:(GDClientCredential *)credential
{
    [self.credentialManager addCredential:credential forAccount:self.persistenceIdentifier];
}

- (void)removeCredential:(GDClientCredential *)credential
{
    [self.credentialManager removeCredential:credential forAccount:self.persistenceIdentifier];
}

- (GDClientCredential *)credential
{
    return [self credentialForUserID:nil];
}

- (GDClientCredential *)credentialForUserID:(NSString *)userID
{
    return [self credentialForUserID:userID apiToken:nil];
}

- (GDClientCredential *)credentialForUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken
{
    return [self credentialMatchingPredicate:[NSPredicate predicateWithBlock:^BOOL(GDClientCredential *credential, __unused NSDictionary *bindings) {
        return ((!userID || [credential.userID isEqualToString:userID])
                && (!apiToken || [credential.apiToken isEqual:apiToken]));
    }]];
}

- (GDClientCredential *)credentialMatchingPredicate:(NSPredicate *)predicate
{
    for (GDClientCredential *credential in self.clientCredentials) {
        if ([credential isValid] && [predicate evaluateWithObject:credential])
            return credential;
    }
    return nil;
}

- (NSArray *)allIndependentCredentials
{
    NSMutableDictionary *credentialsByUserID = [NSMutableDictionary new];
    for (GDClientCredential *clientCredential in self.clientCredentials) {
        if (![clientCredential isValid]) continue;
        
        NSString *userID = clientCredential.userID;
        NSMutableArray *userIDCredentials = credentialsByUserID[userID];
        if (!userIDCredentials) {
            userIDCredentials = [NSMutableArray new];
            credentialsByUserID[userID] = userIDCredentials;
        }
        [userIDCredentials addObject:clientCredential];
    }
    
    NSMutableArray *independentCredentials = [NSMutableArray new];
    [credentialsByUserID enumerateKeysAndObjectsUsingBlock:^(__unused NSString *userID, NSMutableArray *userIDCredentials, __unused BOOL *stop) {
        [userIDCredentials sortUsingSelector:@selector(compare:)];
        
        [independentCredentials addObject:[userIDCredentials lastObject]];
    }];
    
    return [independentCredentials copy];
}

#pragma mark - Client

- (GDHTTPClient *)newClient
{
    return [self newClientForUserID:nil];
}

- (GDHTTPClient *)newClientForUserID:(NSString *)userID
{
    return [self newClientForUserID:userID apiToken:nil];
}

- (GDHTTPClient *)newClientForUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken
{
    GDClientCredential *credential = [self credentialForUserID:userID apiToken:apiToken];
    if (!credential) return nil;
    
    return [self newClientForCredential:credential];
}

- (GDHTTPClient *)newClientForCredential:(GDClientCredential *)credential
{
    Class clientClass = [[self class] clientClass];
    GDHTTPClient *client = [(GDHTTPClient *)[clientClass alloc] initWithClientManager:self credential:credential];
    return client;
}

- (NSArray *)allIndependentClients
{
    NSMutableArray *independentClients = [NSMutableArray new];
    for (GDClientCredential *credential in [self allIndependentCredentials]) {
        GDHTTPClient *client = [self newClientForCredential:credential];
        if (credential)
            [independentClients addObject:client];
    }
    return [independentClients copy];
}

#pragma mark - Linking

- (BOOL)isLinked
{
    return [self.clientCredentials count] > 0;
}

- (void)linkFromController:(UIViewController *)rootController success:(void (^)(id <GDClient> client))success failure:(void (^)(NSError *error))failure
{
    return [self linkUserID:nil fromController:rootController success:success failure:failure];
}

- (void)linkUserID:(NSString *)userID fromController:(UIViewController *)rootController
           success:(void (^)(id <GDClient> client))success
           failure:(void (^)(NSError *error))failure
{
    return [self linkUserID:userID apiToken:self.defaultAPIToken fromController:rootController success:success failure:failure];
}

- (void)linkUserID:(NSString *)__unused userID apiToken:(GDAPIToken *)__unused apiToken
    fromController:(UIViewController *)__unused rootController
           success:(void (^)(id <GDClient> client))__unused success
           failure:(void (^)(NSError *error))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
