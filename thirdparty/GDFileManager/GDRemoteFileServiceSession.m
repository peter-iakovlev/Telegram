//
//  GDRemoteFileServiceSession.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 27/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDRemoteFileServiceSession.h"
#import "GDFileService.h"
#import "GDHTTPClient.h"

@implementation GDRemoteFileServiceSession

+ (NSURL *)baseURLForFileService:(GDFileService *)fileService client:(GDHTTPClient *)client
{
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/", [fileService urlScheme],  client.userID];
    return [NSURL URLWithString:urlString];
}


- (id)initWithFileService:(GDFileService *)fileService client:(GDHTTPClient *)client
{
    NSURL *baseURL = [[self class] baseURLForFileService:fileService client:client];
    
    if ((self = [super initWithBaseURL:baseURL fileService:fileService])) {
        self.client = client;
    }
    
    return self;
}

- (BOOL)isAvailable
{
    return [self.client isAvailable];
}

- (void)unlink
{
    GDFileService *fileService = self.fileService;
    [fileService unlinkSession:self];
}

- (NSOperation *)downloadURL:(NSURL *)__unused url intoFileURL:(NSURL *)__unused localURL
                    progress:(void (^)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead))__unused progress
                     success:(void (^)(NSURL *localURL))__unused success
                     failure:(void (^)(NSError *error))__unused failure
{
    [self doesNotRecognizeSelector:_cmd];
    
    return nil;
}

@end
