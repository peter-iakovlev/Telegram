//
//  GDFileManagerDownloadOperation.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 18/08/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDParentOperation.h"

@class GDFileManager;
@class GDURLMetadata;

@interface GDFileManagerDownloadOperation : GDParentOperation

- (instancetype)initWithFileManager:(GDFileManager *)fileManager sourceURL:(NSURL *)sourceURL
                            success:(void (^)(NSURL *localURL, GDURLMetadata *metadata))success
                            failure:(void (^)(NSError *error))failure;

@property (nonatomic, readonly, strong) GDFileManager *fileManager;
@property (nonatomic, readonly, strong) NSURL *sourceURL;

@property (nonatomic, strong) NSURL *localDestinationFileURL;
@property (nonatomic, strong) NSString *fileVersion;

@property (nonatomic, strong) void (^downloadProgressBlock)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead);

@end
