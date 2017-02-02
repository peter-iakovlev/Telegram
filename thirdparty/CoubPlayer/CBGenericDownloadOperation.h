//
// Created by Tikhonenko Pavel on 27/05/2014.
// Copyright (c) 2014 Coub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBDownloadOperation.h"
#import "CBCoubAsset.h"
#import "CBDownloadOperationDelegate.h"
@class AFHTTPRequestOperation;

@interface CBGenericDownloadOperation : NSObject <CBDownloadOperation>

@property (nonatomic, strong) AFHTTPRequestOperation *downloadOperation;
@property (nonatomic, readwrite) NSOperationQueuePriority queuePriority;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) BOOL starting;
@property (nonatomic, assign) BOOL comleted;
@property (nonatomic, assign) BOOL chunkDownloadingNeeded;

@property (nonatomic, weak) id<CBCoubAsset> coub;
@property (nonatomic, weak) id<CBDownloadOperationDelegate> operationViewDelegate;

@property(nonatomic, copy) void (^clientSuccess)(id<CBCoubAsset>, NSInteger tag);
@property(nonatomic, copy) void (^clientFailure)(id<CBCoubAsset>, NSInteger tag, NSError *error);

@property (nonatomic, copy) void (^completionBlock)(id<CBDownloadOperation> process, NSError *error);

//protected
- (void)successDownload;
- (void)failureDownloadWithError:(NSError *)error;
@end