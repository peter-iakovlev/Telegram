//
//  GDURLMetadata.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 17/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDURLMetadata.h"
#import "GDURLMetadata_Private.h"

#import <objc/runtime.h>

@interface GDURLMetadata ()

@property (nonatomic, strong, readonly) id <GDURLMetadata> metadata;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
@implementation GDURLMetadata
#pragma clang diagnostic pop

- (id)init
{
    return [self initWithURLMetadata:nil clientURL:nil canonicalURL:nil];
}

- (id)initWithURLMetadata:(id<GDURLMetadata>)metadata clientURL:(NSURL *)url canonicalURL:(NSURL *)canonicalURL
{
    if (!metadata || !url) return nil;
    
    if ((self = [super init])) {
        _metadata = metadata;
        _url = url;
        _canonicalURL = canonicalURL;
    }
    
    return self;
}

- (id)initWithMetadataDictionary:(NSDictionary *)__unused metadataDictionary
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    struct objc_method_description method_description = protocol_getMethodDescription(@protocol(GDURLMetadata), aSelector, YES, YES);
    if (method_description.name) {
        return self.metadata;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (id <GDURLMetadata>)cacheableMetadata
{
    return self.metadata;
}

- (GDGoogleDriveURLMetadata *)driveMetadata
{
    return (GDGoogleDriveURLMetadata *)self.metadata;
}

- (NSDictionary *)jsonDictionary
{
    return [self.metadata jsonDictionary];
}

#pragma mark - NSCoding

static NSString *const kMetadataClassName = @"MetadataClassName";
static NSString *const kMetadataDictionary = @"MetadataDictionary";
static NSString *const kMetadataClientURL = @"MetadataClientURL";
static NSString *const kMetadataCanonicalURL = @"MetadataCanonicalURL";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    Class <GDURLMetadata> metadataClass = NSClassFromString([aDecoder decodeObjectForKey:kMetadataClassName]);
    NSDictionary *metadataDictionary = [aDecoder decodeObjectForKey:kMetadataDictionary];
    NSURL *clientURL = [aDecoder decodeObjectForKey:kMetadataClientURL];
    NSURL *canonicalURL = [aDecoder decodeObjectForKey:kMetadataCanonicalURL];
    
    id <GDURLMetadata> metadata = [(id<GDURLMetadata>)[metadataClass alloc] initWithMetadataDictionary:metadataDictionary];
    
    return [self initWithURLMetadata:metadata clientURL:clientURL canonicalURL:canonicalURL];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:NSStringFromClass([self.metadata class]) forKey:kMetadataClassName];
    [aCoder encodeObject:self.jsonDictionary forKey:kMetadataDictionary];
    [aCoder encodeObject:self.url forKey:kMetadataClientURL];
    [aCoder encodeObject:self.canonicalURL forKey:kMetadataCanonicalURL];
}

@end
