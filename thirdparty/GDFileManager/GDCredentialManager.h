//
//  GDCredentialManager.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 11/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDClientCredential;
@class GDAPIToken;

@interface GDCredentialManager : NSObject

+ (GDCredentialManager *)sharedCredentialManager;
+ (void)setSharedCredentialManager:(GDCredentialManager *)credentialManager;

// Credentials

- (void)addCredential:(GDClientCredential *)credential forAccount:(NSString *)account;
- (void)removeCredential:(GDClientCredential *)credential forAccount:(NSString *)account;

- (NSArray *)clientCredentialsForAccount:(NSString *)account;

@end
