//
//  GDGoogleDriveClientManager.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 24/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDGoogleDriveClientManager.h"
#import "GDGoogleDriveClient.h"
#import "GDGoogleDriveAccountInfo.h"

@implementation GDGoogleDriveClientManager

@dynamic defaultAPIToken;

+ (Class)apiTokenClass
{
    return [GDGoogleDriveAPIToken class];
}

+ (Class)clientClass
{
    return [GDGoogleDriveClient class];
}

@end

