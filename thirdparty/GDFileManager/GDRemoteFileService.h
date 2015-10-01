//
//  GDRemoteFileService.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileService.h"

@class GDAPIToken;
@class GDClientManager;

@interface GDRemoteFileService : GDFileService

// Implementation

- (id)initWithClientManager:(GDClientManager *)clientManager;

- (void)linkFromController:(UIViewController *)rootController
                  apiToken:(GDAPIToken *)apiToken
                   success:(void (^)(GDFileServiceSession *fileServiceSession))success
                   failure:(void (^)(NSError *error))failure;

@property (nonatomic, strong, readonly) GDClientManager *clientManager;

// Subclasses must override
+ (Class)clientManagerClass;

- (void)linkUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken
    fromController:(UIViewController *)rootController
           success:(void (^)(GDFileServiceSession *fileServiceSession))success
           failure:(void (^)(NSError *error))failure;


@end
