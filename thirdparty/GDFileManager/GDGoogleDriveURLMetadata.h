//
//  GDGoogleDriveURLMetadata.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 29/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDURLMetadata.h"
#import "GDURLMetadataInternal.h"

@class GDGoogleDriveMetadata;

@interface GDGoogleDriveURLMetadata : NSObject <GDURLMetadata>

- (id)initWithGoogleDriveMetadata:(GDGoogleDriveMetadata *)metadata;

@property (nonatomic, readonly, strong) GDGoogleDriveMetadata *metadata;

@property (nonatomic, copy, readonly)  NSString *fileID;
@property (nonatomic, copy, readonly)  NSString *etag;


@end
