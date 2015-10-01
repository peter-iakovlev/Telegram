//
//  GDOAuth2Credential.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 24/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDOAuth2Credential.h"
#import "GDGoogleDriveClient.h"

@interface AFOAuthCredential (ExpirationDate)

@property (readonly, nonatomic) NSDate *expiration;

@end

@implementation GDOAuth2Credential

- (id)initWithUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken
{
    return [self initWithOAuthCredential:nil userID:userID apiToken:apiToken];
}

- (id)initWithOAuthCredential:(AFOAuthCredential *)oauthCredential userID:(NSString *)userID apiToken:(GDAPIToken *)apiToken
{
    NSParameterAssert(oauthCredential);
    
    if ((self = [super initWithUserID:userID apiToken:apiToken])) {
        _oauthCredential = oauthCredential;
    }
    
    return self;
}

- (BOOL)isValid
{
    return (self.oauthCredential.refreshToken || [self isAccessTokenValid]) && self.apiToken;
}

- (BOOL)isAccessTokenValid
{
    return self.oauthCredential.accessToken && ![self.oauthCredential isExpired];
}

- (BOOL)canBeRenewed
{
    return !!self.oauthCredential.refreshToken;
}

- (NSDate *)accessTokenExpirationDate
{
    return self.oauthCredential.expiration;
}

#pragma mark - NSCoding

static NSString *const kOAuthCredentialKey = @"oauthCredential";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _oauthCredential = [aDecoder decodeObjectForKey:kOAuthCredentialKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.oauthCredential forKey:kOAuthCredentialKey];
}

@end
