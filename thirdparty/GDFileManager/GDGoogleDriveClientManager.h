//
//  GDGoogleDriveClientManager.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 24/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDClientManager.h"
#import "GDGoogleDriveAPIToken.h"

@class GDGoogleDriveClient;

@interface GDGoogleDriveClientManager : GDClientManager

@property (nonatomic, strong) GDGoogleDriveAPIToken *defaultAPIToken;

@end
