//
//  GDGoogleDriveURLMetadata.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 29/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDGoogleDriveURLMetadata.h"
#import "GDGoogleDrive.h"

@implementation GDGoogleDriveURLMetadata

@synthesize driveMetadata;

- (id)initWithMetadataDictionary:(NSDictionary *)metadataDictionary
{
    return [self initWithGoogleDriveMetadata:[[GDGoogleDriveMetadata alloc] initWithDictionary:metadataDictionary]];
}

- (id)initWithGoogleDriveMetadata:(GDGoogleDriveMetadata *)metadata
{
    if ((self = [super init])) {
        _metadata = metadata;
    }
    
    return self;
}

- (NSDictionary *)jsonDictionary
{
    return self.metadata.backingStore;
}

- (id <GDURLMetadata>)cacheableMetadata {return self;}

#pragma mark - call through to GDGoogleDriveMetadata

- (BOOL)isDirectory { return [self.metadata isDirectory]; }
- (BOOL)isReadOnly { return ![self.metadata isEditable]; }
- (NSInteger)fileSize { return self.metadata.fileSize; }
- (NSString *)fileVersionIdentifier { return self.metadata.headRevisionIdentifier; }
- (NSString *)etag { return self.metadata.etag; }

- (NSString *)fileID { return self.metadata.identifier; }
- (NSString *)filename { return self.metadata.title; }

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", [super description], [self.metadata description]];
}

- (BOOL)isValid { return [self fileID] != nil; }

@end
