//
//  GDGoogleDriveChange.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 27/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDGoogleDriveChange.h"
#import "GDGoogleDriveMetadata.h"

@implementation GDGoogleDriveChange

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super initWithDictionary:dictionary])) {
        [self createMetadataObject];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self createMetadataObject];
    }
    
    return self;
}

- (void)createMetadataObject
{
    NSDictionary *fileMetadataDictionary = self.backingStore[@"file"];
    if (fileMetadataDictionary)
        _fileMetadata = [[GDGoogleDriveMetadata alloc] initWithDictionary:self.backingStore[@"file"]];
}

@end
