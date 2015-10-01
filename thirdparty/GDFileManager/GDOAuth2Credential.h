//
//  GDOAuth2Credential.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 24/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDAccessTokenClientCredential.h"
#import "AFOAuth2Client.h"

@interface GDOAuth2Credential : GDAccessTokenClientCredential

- (id)initWithOAuthCredential:(AFOAuthCredential *)oauthCredential userID:(NSString *)userID apiToken:(GDAPIToken *)apiToken;

@property (nonatomic, strong, readonly) AFOAuthCredential *oauthCredential;

@end
