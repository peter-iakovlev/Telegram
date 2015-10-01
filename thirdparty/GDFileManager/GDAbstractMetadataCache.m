//
//  GDAbstractMetadataCache.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 15/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDAbstractMetadataCache.h"
#import "GDAbstractMetadataCache_Private.h"
#import "GDURLMetadata.h"
#import "GDURLMetadataInternal.h"

@interface GDAbstractMetadataCache ()

@property (nonatomic) dispatch_queue_t isolationQueue;

@end

@implementation GDAbstractMetadataCache

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    if (self.isolationQueue) {
        dispatch_release(self.isolationQueue);
        self.isolationQueue = NULL;
    }
}
#endif

- (id)init
{
    if ((self = [super init])) {
        self.isolationQueue = dispatch_queue_create("me.grahamdennis.GDDiscardingMetadataCache", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (id <GDURLMetadata>)metadataForURL:(NSURL *)url
{
    return [self metadataForURL:url directoryContents:NULL];
}

- (void)setMetadata:(id<GDURLMetadata>)metadata forURL:(NSURL *)url
{
    [self setMetadata:metadata forURL:url addToParent:nil];
}

- (void)setMetadata:(id <GDURLMetadata>)metadata forURL:(NSURL *)url addToParent:(NSURL *)parentURL
{
    [self setMetadata:metadata directoryContents:nil forURL:url addToParent:parentURL];
}

- (NSArray *)directoryContentsForURL:(NSURL *)url
{
    NSArray *directoryContents = nil;
    [self metadataForURL:url directoryContents:&directoryContents];
    
    return directoryContents;
}

- (void)setDirectoryContents:(NSDictionary *)contents forURL:(NSURL *)url
{
    [self setMetadata:nil directoryContents:contents forURL:url addToParent:nil];
}

- (id <GDURLMetadata>)metadataForURL:(NSURL *)url directoryContents:(NSArray *__autoreleasing *)contents
{
    GDFileTreeNode *treeNode = [self treeNodeForURL:url];
    if (contents) {
        if ([treeNode.directoryContents count] == 0)
            *contents = treeNode.directoryContents;
        else {
            NSMutableArray *urlArray = [NSMutableArray arrayWithCapacity:[treeNode.directoryContents count]];
            for (GDFileTreeNode *childNode in treeNode.directoryContents) {
                [urlArray addObject:childNode.url];
            }
            *contents = [urlArray copy];
        }
    }
    return treeNode.metadata;
}

- (void)setMetadata:(id<GDURLMetadata>)metadata
  directoryContents:(NSDictionary *)contents
             forURL:(NSURL *)url
        addToParent:(NSURL *)parentURL
{
    NSParameterAssert(url);
    if (!metadata && !contents) return;
    
    dispatch_barrier_async(self.isolationQueue, ^{
        GDFileTreeNode *treeNode = [self treeNodeForURL:url] ?: [[GDFileTreeNode alloc] initWithURL:url];
        
        if (metadata) treeNode.metadata = [metadata cacheableMetadata];
        if (contents) {
            if ([contents count] == 0) {
                treeNode.directoryContents = [contents allKeys];
            } else {
                NSMutableArray *directoryContents = [NSMutableArray arrayWithCapacity:[contents count]];
                NSNull *null = [NSNull null];
                [contents enumerateKeysAndObjectsUsingBlock:^(NSURL *childURL, id <GDURLMetadata> childMetadata, __unused BOOL *stop) {
                    GDFileTreeNode *childTreeNode = [self treeNodeForURL:childURL] ?: [[GDFileTreeNode alloc] initWithURL:childURL];
                    [directoryContents addObject:childTreeNode];
                    if (![childMetadata isEqual:null]) {
                        childTreeNode.metadata = [childMetadata cacheableMetadata];
                    }
                    [self setTreeNode:childTreeNode forURL:childURL];
                }];
                treeNode.directoryContents = directoryContents;
            }
        }
        if (parentURL) {
            GDFileTreeNode *parentNode = [self treeNodeForURL:parentURL];
            if (parentNode.directoryContents && ![parentNode.directoryContents containsObject:treeNode]) {
                NSArray *directoryContents = [parentNode.directoryContents arrayByAddingObject:treeNode];
                parentNode.directoryContents = directoryContents;
            }
        }
        [self setTreeNode:treeNode forURL:url];
    });
}

- (void)removeMetadataForURL:(NSURL *)url removeFromParent:(NSURL *)parentURL
{
    NSParameterAssert(url);
    
    dispatch_barrier_async(self.isolationQueue, ^{
        GDFileTreeNode *treeNode = [self treeNodeForURL:url];
        
        if (treeNode) {
            [self removeTreeNodeForURL:url];
            if (parentURL) {
                GDFileTreeNode *parentTreeNode = [self treeNodeForURL:parentURL];
                if (parentTreeNode.directoryContents) {
                    NSMutableArray *directoryContents = [parentTreeNode.directoryContents mutableCopy];
                    [directoryContents removeObjectIdenticalTo:treeNode];
                    parentTreeNode.directoryContents = [directoryContents copy];
                }
            }
        }
    });
}


- (NSArray *)directoryContentsMetadataArrayForURL:(NSURL *)url
{
    NSArray *directoryContentsURLs = [self directoryContentsForURL:url];
    if ([directoryContentsURLs count] == 0) return directoryContentsURLs;
    
    NSMutableArray *metadataArray = [NSMutableArray arrayWithCapacity:[directoryContentsURLs count]];
    for (NSURL *childURL in directoryContentsURLs) {
        id <GDURLMetadata> metadata = [self metadataForURL:childURL];
        if (!metadata) return nil;
        [metadataArray addObject:metadata];
    }
    return [metadataArray copy];
}



#pragma mark - Subclasses to provide
- (void)reset
{
    [self doesNotRecognizeSelector:_cmd];
}

- (GDFileTreeNode *)treeNodeForURL:(NSURL *)__unused url
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setTreeNode:(GDFileTreeNode *)__unused treeNode forURL:(NSURL *)__unused url
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)removeTreeNodeForURL:(NSURL *)__unused url
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
