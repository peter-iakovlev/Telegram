//
//  GDGoogleDriveFileService.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 29/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDGoogleDriveFileService.h"
#import "GDGoogleDriveFileServiceSession.h"
#import "GDGoogleDrive.h"

static NSString *const GDGoogleDriveFileServiceURLScheme   = @"drive";

@interface GDGoogleDriveFileService ()

//@property (nonatomic, readonly, strong) GDGoogleDriveClientManager *clientManager;

@end

@implementation GDGoogleDriveFileService

+ (Class)clientManagerClass
{
    return [GDGoogleDriveClientManager class];
}

+ (Class)fileServiceSessionClass
{
    return [GDGoogleDriveFileServiceSession class];
}

- (NSString *)urlScheme
{
    return GDGoogleDriveFileServiceURLScheme;
}

- (NSString *)name
{
    return @"Google Drive";
}

- (void)linkUserID:(NSString *)userID apiToken:(GDAPIToken *)apiToken
    fromController:(UIViewController *)rootController
           success:(void (^)(GDFileServiceSession *fileServiceSession))success
           failure:(void (^)(NSError *error))failure
{
    [self.clientManager linkUserID:userID apiToken:apiToken fromController:rootController
                           success:^(GDGoogleDriveClient *client) {
                               GDGoogleDriveFileServiceSession *session = [[GDGoogleDriveFileServiceSession alloc] initWithFileService:self client:client];
                               [self addFileServiceSession:session];
                               if (success) success(session);
                           } failure:failure];
}


@end
