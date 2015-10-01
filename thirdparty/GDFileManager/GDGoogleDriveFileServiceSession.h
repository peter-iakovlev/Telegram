//
//  GDGoogleDriveFileServiceSession.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 29/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDRemoteFileServiceSession.h"
#import "GDGoogleDrive.h"

@interface GDGoogleDriveFileServiceSession : GDRemoteFileServiceSession

@property (nonatomic, strong) GDGoogleDriveClient *client;

@end
