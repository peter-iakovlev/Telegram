//
//  GDParentOperation.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 4/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDHTTPClient, AFHTTPRequestOperation;

#import "GDParentOperation.h"

extern NSString * const GDHTTPStatusErrorDomain;

@interface GDHTTPOperation : GDParentOperation

@property (nonatomic, strong, readonly) GDHTTPClient *client;
@property (nonatomic, strong) NSMutableURLRequest *urlRequest;
@property (nonatomic) BOOL requiresAuthentication;
@property (nonatomic) BOOL retryOnStandardErrors;

@property (nonatomic, strong, readonly) void (^success)(AFHTTPRequestOperation *requestOperation, id responseObject);
@property (nonatomic, strong, readonly) void (^failure)(AFHTTPRequestOperation *requestOperation, NSError *error);

@property (nonatomic, strong) BOOL (^shouldRetryAfterError)(NSError *error);
@property (nonatomic, strong) void (^configureOperationBlock)(AFHTTPRequestOperation *requestOperation);

- (id)initWithClient:(GDHTTPClient *)client urlRequest:(NSMutableURLRequest *)urlRequest
             success:(void (^)(AFHTTPRequestOperation *requestOperation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *requestOperation, NSError *error))failure;


@end
