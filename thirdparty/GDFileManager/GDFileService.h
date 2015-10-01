//
//  GDFileService.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDHTTPOperation.h"

@class GDFileServiceSession;
@protocol GDURLMetadata;

@interface GDFileService : NSObject <NSCoding>

+ (Class)fileServiceSessionClass;

// Root class interface
- (NSArray *)urlSchemes;

- (void)addFileServiceSession:(GDFileServiceSession *)fileServiceSession;
- (void)removeFileServiceSession:(GDFileServiceSession *)fileServiceSession;

- (GDFileServiceSession *)fileServiceSessionForURL:(NSURL *)url;

@property (nonatomic, readonly, copy) NSArray *fileServiceSessions;

@property (nonatomic, readonly) dispatch_queue_t isolationQueue;
@property (nonatomic, readonly) dispatch_queue_t workQueue;

// Subclasses should override
- (NSString *)urlScheme;
- (BOOL)shouldCacheResults;
- (BOOL)handleOpenURL:(NSURL *)url;

- (NSString *)name;

- (void)linkFromController:(UIViewController *)rootController
                   success:(void (^)(GDFileServiceSession *fileServiceSession))success
                   failure:(void (^)(NSError *error))failure;

- (void)unlinkSession:(GDFileServiceSession *)session;

@end
