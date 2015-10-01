//
//  GDFileManagerDownloadOperation.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 18/08/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileManagerDownloadOperation.h"
#import "GDFileManagerDownloadOperation_Private.h"

#import "GDFileManager_Private.h"

#import "GDFileServiceManager.h"
#import "GDFileServiceSession.h"

@implementation GDFileManagerDownloadOperation

@synthesize localDestinationFileURL = _localDestinationFileURL;

- (instancetype)initWithFileManager:(GDFileManager *)fileManager sourceURL:(NSURL *)sourceURL
                            success:(void (^)(NSURL *localURL, GDURLMetadata *metadata))success
                            failure:(void (^)(NSError *error))failure
{
    if ((self = [super init])) {
        _fileManager = fileManager;
        _sourceURL = [sourceURL copy];
        
        __block typeof(self) strongSelf = self;
        dispatch_block_t cleanup = ^{[strongSelf finish]; strongSelf->_success = nil; strongSelf->_failure = nil; strongSelf.downloadProgressBlock = nil; strongSelf = nil;};
        
        _success = ^(NSURL *localURL, GDURLMetadata *metadata){
            dispatch_async(strongSelf.successCallbackQueue, ^{
                if (success) success(localURL, metadata);
                cleanup();
            });
        };
        _failure = ^(NSError *error){
            dispatch_async(strongSelf.failureCallbackQueue, ^{
                if (failure) failure(error);
                cleanup();
            });
        };

    }
    return self;
}

- (NSURL *)localDestinationFileURL
{
    if (!_localDestinationFileURL) {
        NSString *uuidString = nil;
        {
            CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
            uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
            CFRelease(uuid);
        }
        
        _localDestinationFileURL = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES] URLByAppendingPathComponent:uuidString];
    }
    return _localDestinationFileURL;
}

- (void)main
{
    [self downloadFile];
}

- (void)downloadFile
{
    if ([self isCancelled]) return self.failure(GDOperationCancelledError);
    
    GDFileManager *fileManager = self.fileManager;
    GDFileServiceSession *session = [fileManager.fileServiceManager fileServiceSessionForURL:self.sourceURL];
    
    NSURL *canonicalURL = [session canonicalURLForURL:self.sourceURL];
    if (!canonicalURL) {
        return self.failure(GDFileManagerError(GDFileManagerNoCanonicalURLError));
    }
    
    if (!self.localDestinationFileURL) {
        return self.failure(GDFileManagerError(GDFileManagerNoLocalURLError));
    } else if (![self.localDestinationFileURL isFileURL]) {
        return self.failure(GDFileManagerError(GDFileManagerLocalURLNotFileURLError));
    }
    
    NSOperation *childOperation = [session downloadURL:self.sourceURL intoFileURL:self.localDestinationFileURL fileVersion:self.fileVersion
                                              progress:self.downloadProgressBlock
                                               success:^(NSURL *localURL, GDURLMetadata *metadata) {
                                                   [fileManager cacheClientMetadata:metadata];
                                                   _localDestinationFileURL = localURL;
                                                   self.success(localURL, metadata);
                                               }
                                               failure:self.failure];
    
    [self addChildOperation:childOperation];
}

@end
