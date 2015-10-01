//
//  GDKeychainCredentialManager.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 11/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDKeychainCredentialManager.h"

#import "GDCredentialManager_Private.h"

#import "SSKeychain.h"

static NSString * const GDKeychainCredentialManagerKeychainKey = @"GDKeychainCredentialManagerKeychainKey";

@implementation GDKeychainCredentialManager

- (NSArray *)loadCredentialsForAccount:(NSString *)account
{
    SSKeychainQuery *query = [SSKeychainQuery new];
    query.account = account;
    query.service = GDKeychainCredentialManagerKeychainKey;
    
    NSError *error = nil;
    if ([query fetch:&error] && [(id)query.passwordObject isKindOfClass:[NSArray class]]) {
        return [(NSArray *)query.passwordObject copy];
    }
    return [NSArray new];
}

- (void)saveCredentials:(NSArray *)credentials forAccount:(NSString *)account
{
    SSKeychainQuery *query = [SSKeychainQuery new];
    query.account = account;
    query.service = GDKeychainCredentialManagerKeychainKey;
    
    query.passwordObject = credentials;
    
    NSError *error = nil;
    if (![query save:&error]) {
        NSLog(@"Failed to save to keychain with error: %@", error);
    }
}

@end
