//
//  GDAccessTokenClientCredential.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 4/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDClientCredential.h"

@interface GDAccessTokenClientCredential : GDClientCredential

- (BOOL)isAccessTokenValid;

- (void)getRenewedAccessTokenUsingClient:(GDHTTPClient *)client
                                 success:(void (^)(GDClientCredential *credential, BOOL isFreshFromRemote))success
                                 failure:(void (^)(NSError *error))failure;

@property (nonatomic, readonly, copy) NSDate *accessTokenExpirationDate;

@end
