//
//  GDFileManagerAlias.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 21/08/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileManagerAlias.h"
#import "GDFileManager.h"
#import "GDDispatchUtilities.h"

@interface GDFileManagerAlias ()

@property (nonatomic, readonly, copy) NSArray *metadataHeirarchy;

@end

@implementation GDFileManagerAlias

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithMetadataHeirarchy:(NSArray *)metadataHeirarchy
{
    if ((self = [super init])) {
        _metadataHeirarchy = [metadataHeirarchy copy];
    }
    return self;
}

- (NSURL *)originalURL
{
    return self.originalMetadata.url;
}

- (GDURLMetadata *)originalMetadata
{
    return [self.metadataHeirarchy lastObject];
}

- (NSString *)originalFilenamePath
{
    NSMutableArray *pathComponents = [NSMutableArray arrayWithCapacity:[self.metadataHeirarchy count]+1];
    // first / as this is an absolute path
    for (GDURLMetadata *pathComponentMetadata in self.metadataHeirarchy) {
        [pathComponents addObject:pathComponentMetadata.filename];
    }
    if ([pathComponents count] && ![[pathComponents objectAtIndex:0] isEqualToString:@"/"]) {
        [pathComponents insertObject:@"/" atIndex:0];
    }
    return [NSString pathWithComponents:pathComponents];
}

#pragma mark - NSCoding

static NSString *const kMetadataHeirarchy = @"metadataHeirarchy";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSArray *metadataHeirarchy = [aDecoder decodeObjectForKey:kMetadataHeirarchy];
    return [self initWithMetadataHeirarchy:metadataHeirarchy];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.metadataHeirarchy forKey:kMetadataHeirarchy];
}

@end
