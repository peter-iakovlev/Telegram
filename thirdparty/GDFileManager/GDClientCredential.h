//
//  GDCredential.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDAPIToken;
@class GDHTTPClient;

@interface GDClientCredential : NSObject <NSCoding>

- (id)initWithUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken;

- (BOOL)isValid;
- (BOOL)canBeRenewed;
- (NSComparisonResult)compare:(GDClientCredential *)otherCredential;

@property (nonatomic, strong, readonly) GDAPIToken *apiToken;
@property (nonatomic, copy, readonly) NSString *userID;

@end
