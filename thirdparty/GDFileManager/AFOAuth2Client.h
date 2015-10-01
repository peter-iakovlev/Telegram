// AFOAuth2Client.h
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "thirdparty/AFNetworking/AFHTTPClient.h"

#ifndef _SECURITY_SECITEM_H_
#warning Security framework not found in project, or not included in precompiled header. Keychain persistence functionality will not be available.
#endif

@class AFOAuthCredential;

/**
 
 */
@interface AFOAuth2Client : AFHTTPClient

///------------------------------------------
/// @name Accessing OAuth 2 Client Properties
///------------------------------------------

/**
 
 */
@property (readonly, nonatomic) NSString *serviceProviderIdentifier;

/**
 
 */
@property (readonly, nonatomic) NSString *clientID;

///------------------------------------------------
/// @name Creating and Initializing OAuth 2 Clients
///------------------------------------------------

/**
 
 */
+ (instancetype)clientWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret;

/**
 
 */
- (id)initWithBaseURL:(NSURL *)url
             clientID:(NSString *)clientID
               secret:(NSString *)secret;

/**
 
 */
- (void)setAuthorizationHeaderWithCredential:(AFOAuthCredential *)credential;

///---------------------
/// @name Authenticating
///---------------------

/**
 
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path
                                  code:(NSString *)code
                           redirectURI:(NSString *)uri
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure;

/**
 
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path
                              username:(NSString *)username
                              password:(NSString *)password
                                 scope:(NSString *)scope
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure;

/**
 
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path
                                 scope:(NSString *)scope
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure;

/**
 
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path
                          refreshToken:(NSString *)refreshToken
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure;

/**
 
 */
- (void)authenticateUsingOAuthWithPath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                               success:(void (^)(AFOAuthCredential *credential))success
                               failure:(void (^)(NSError *error))failure;

@end

#pragma mark -

/**
 
 */
@interface AFOAuthCredential : NSObject <NSCoding>

///--------------------------------------
/// @name Accessing Credential Properties
///--------------------------------------

/**
 
 */
@property (readonly, nonatomic) NSString *accessToken;

/**
 
 */
@property (readonly, nonatomic) NSString *tokenType;

/**
 
 */
@property (readonly, nonatomic) NSString *refreshToken;

/**
 
 */
@property (readonly, nonatomic, assign, getter = isExpired) BOOL expired;

///--------------------------------------------
/// @name Creating and Initializing Credentials
///--------------------------------------------

/**
 
 */
+ (instancetype)credentialWithOAuthToken:(NSString *)token
                               tokenType:(NSString *)type;

/**
 
 */
- (id)initWithOAuthToken:(NSString *)token
               tokenType:(NSString *)type;

///----------------------------
/// @name Setting Refresh Token
///----------------------------

/**
 
 */
- (void)setRefreshToken:(NSString *)refreshToken
             expiration:(NSDate *)expiration;

///-----------------------------------------
/// @name Storing and Retrieving Credentials
///-----------------------------------------

#ifdef _SECURITY_SECITEM_H_
/**

 */
+ (BOOL)storeCredential:(AFOAuthCredential *)credential
         withIdentifier:(NSString *)identifier;

/**

 */
+ (BOOL)deleteCredentialWithIdentifier:(NSString *)identifier;

/**

 */
+ (AFOAuthCredential *)retrieveCredentialWithIdentifier:(NSString *)identifier;
#endif

@end

///----------------
/// @name Constants
///----------------

/**
 
 */
extern NSString * const kAFOAuthCodeGrantType;
extern NSString * const kAFOAuthClientCredentialsGrantType;
extern NSString * const kAFOAuthPasswordCredentialsGrantType;
extern NSString * const kAFOAuthRefreshGrantType;
