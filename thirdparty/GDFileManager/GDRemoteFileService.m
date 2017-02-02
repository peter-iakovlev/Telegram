//
//  GDRemoteFileService.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDRemoteFileService.h"
#import "GDAPIToken.h"
#import "GDClientManager.h"
#import "GDRemoteFileServiceSession.h"
#import "GDHTTPClient.h"

@interface GDRemoteFileService ()

- (NSString *)persistenceIdentifierForClientManager;

@end

@implementation GDRemoteFileService

+ (Class)apiTokenClass { return nil; }
+ (Class)clientManagerClass  { return nil; }

- (id)init
{
    Class apiTokenClass = [[self class] apiTokenClass];
    
    return [self initWithAPIToken:[apiTokenClass sharedToken]];
}

- (id)initWithAPIToken:(GDAPIToken *)apiToken
{
    Class clientManagerClass = [[self class] clientManagerClass];
    
    GDClientManager *clientManager = (GDClientManager *)[clientManagerClass new];
    clientManager.defaultAPIToken = apiToken;
    clientManager.persistenceIdentifier = [self persistenceIdentifierForClientManager];
    
    return [self initWithClientManager:clientManager];
}

- (id)initWithClientManager:(GDClientManager *)clientManager
{
    if ((self = [super init])) {
        _clientManager = clientManager;
    }
    
    return self;
}

#pragma mark - NSCoding

#pragma mark - Linking

- (void)linkFromController:(UIViewController *)rootController
                   success:(void (^)(GDFileServiceSession *fileServiceSession))success
                   failure:(void (^)(NSError *error))failure
{
    return [self linkFromController:rootController apiToken:self.clientManager.defaultAPIToken
                            success:success failure:failure];
}

- (void)linkFromController:(UIViewController *)rootController
                  apiToken:(GDAPIToken *)apiToken
                   success:(void (^)(GDFileServiceSession *fileServiceSession))success
                   failure:(void (^)(NSError *error))failure
{
    return [self linkUserID:nil apiToken:apiToken fromController:rootController success:success failure:failure];
}


- (void)linkUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken
    fromController:(UIViewController *)rootController
           success:(void (^)(GDFileServiceSession *fileServiceSession))__unused success
           failure:(void (^)(NSError *error))failure
{
    return [self.clientManager linkUserID:userID apiToken:apiToken fromController:rootController success:^(__unused id client) {

    } failure:failure];
}

- (void)unlinkSession:(GDFileServiceSession *)session
{
    [super unlinkSession:session];
    
    [self.clientManager removeCredential:[[(GDRemoteFileServiceSession *)session client] credential]];
}

#pragma mark - Private

- (NSString *)persistenceIdentifierForClientManager
{
    return [NSString stringWithFormat:@"%@/%@", NSStringFromClass([self class]), NSStringFromClass([[self class] clientManagerClass])];
}

@end
