//
//  GDClientManager.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 23/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDAPIToken;
@class GDClientCredential;
@class GDHTTPClient;
@class GDCredentialManager;
@protocol GDClient;

@interface GDClientManager : NSObject

+ (Class)apiTokenClass;
+ (Class)clientClass;

+ (instancetype)sharedManager;

- (void)setDefaultKey:(NSString *)key secret:(NSString *)secret;

// Credentials

- (void)addCredential:(GDClientCredential *)credential;
- (void)removeCredential:(GDClientCredential *)credential;

- (id)credential;
- (id)credentialForUserID:(NSString *)userID;
- (id)credentialForUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken;
- (GDClientCredential *)credentialMatchingPredicate:(NSPredicate *)predicate;

- (NSArray *)allIndependentCredentials;

- (BOOL)isValid;

@property (nonatomic, strong) GDCredentialManager *credentialManager;

// Client

- (id)newClient;
- (id)newClientForUserID:(NSString *)userID;
- (id)newClientForUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken;
- (id)newClientForCredential:(GDClientCredential *)credential;

- (NSArray *)allIndependentClients;

// Linking

- (BOOL)isLinked;

- (void)linkFromController:(UIViewController *)rootController
                   success:(void (^)(id <GDClient> client))success
                   failure:(void (^)(NSError *error))failure;

- (void)linkUserID:(NSString *)userID fromController:(UIViewController *)rootController
           success:(void (^)(id <GDClient> client))success
           failure:(void (^)(NSError *error))failure;

- (void)linkUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken
    fromController:(UIViewController *)rootController
           success:(void (^)(id <GDClient> client))success
           failure:(void (^)(NSError *error))failure;

@property (nonatomic, strong) GDAPIToken *defaultAPIToken;
@property (nonatomic, strong) NSString *persistenceIdentifier;

@end
