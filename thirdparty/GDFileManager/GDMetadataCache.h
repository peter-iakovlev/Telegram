//
//  GDMetadataCache.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 15/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GDURLMetadata;

@protocol GDMetadataCache <NSObject>

- (id <GDURLMetadata>)metadataForURL:(NSURL *)url;
- (void)setMetadata:(id <GDURLMetadata>)metadata forURL:(NSURL *)url;
- (void)setMetadata:(id<GDURLMetadata>)metadata forURL:(NSURL *)url addToParent:(NSURL *)parentURL;

- (void)removeMetadataForURL:(NSURL *)url removeFromParent:(NSURL *)parentURL;

- (void)setDirectoryContents:(NSDictionary *)contents forURL:(NSURL *)url;
- (NSArray *)directoryContentsForURL:(NSURL *)url;

- (NSArray *)directoryContentsMetadataArrayForURL:(NSURL *)url;

- (void)setMetadata:(id<GDURLMetadata>)metadata directoryContents:(NSDictionary *)contents forURL:(NSURL *)url addToParent:(NSURL *)parentURL;
- (id <GDURLMetadata>)metadataForURL:(NSURL *)url directoryContents:(NSArray **)contents;

- (void)reset;

@end
