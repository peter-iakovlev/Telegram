//
//  GDFileManager_Private.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 5/08/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileManager.h"

@class GDFileServiceSession;

@interface GDFileManager ()

@property (nonatomic, strong) id <GDMetadataCache> layeredCache;

- (GDURLMetadata *)clientMetadataForURLMetadata:(id <GDURLMetadata>)metadata clientURL:(NSURL *)clientURL
                             fileServiceSession:(GDFileServiceSession *)session cache:(id <GDMetadataCache>)cache;


- (void)cacheClientMetadata:(GDURLMetadata *)metadata;
- (void)cacheClientMetadata:(GDURLMetadata *)metadata addToParent:(BOOL)addToParent;
- (void)cacheClientMetadataContents:(NSArray *)contents forURL:(NSURL *)url;

@end
