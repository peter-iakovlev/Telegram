//
//  GDRemoteFileServiceSession.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 27/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileServiceSession.h"

@class GDHTTPClient;
@class GDRemoteFileService;
@class AFHTTPRequestOperation;

@interface GDRemoteFileServiceSession : GDFileServiceSession

- (id)initWithFileService:(GDFileService *)fileService client:(GDHTTPClient *)client;

@property (nonatomic, strong) GDHTTPClient *client;

// Subclasses to provide
+ (NSURL *)baseURLForFileService:(GDFileService *)fileService client:(GDHTTPClient *)client;

- (NSOperation *)downloadURL:(NSURL *)url intoFileURL:(NSURL *)localURL
                    progress:(void (^)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                     success:(void (^)(NSURL *localURL))success
                     failure:(void (^)(NSError *error))failure;

@end
