//
//  GDRetainingMetadataCache.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 16/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDRetainingMetadataCache.h"
#import "GDAbstractMetadataCache_Private.h"

@interface GDRetainingMetadataCache ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic) dispatch_queue_t accessQueue;

@end

@implementation GDRetainingMetadataCache

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    if (self.accessQueue) {
        dispatch_release(self.accessQueue);
        self.accessQueue = NULL;
    }
}
#endif

- (id)init
{
    if ((self = [super init])) {
        self.dictionary = [NSMutableDictionary new];
        self.accessQueue = dispatch_queue_create("me.grahamdennis.GDRetainingMetadataCache", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (void)reset
{
    dispatch_barrier_async(self.accessQueue, ^{
        [self.dictionary removeAllObjects];
    });
}

- (GDFileTreeNode *)treeNodeForURL:(NSURL *)url
{
    __block GDFileTreeNode *treeNode = nil;
    dispatch_sync(self.accessQueue, ^{
        treeNode = [self.dictionary objectForKey:url];
    });
    return treeNode;
}

- (void)setTreeNode:(GDFileTreeNode *)treeNode forURL:(NSURL *)url
{
    dispatch_barrier_async(self.accessQueue, ^{
        [self.dictionary setObject:treeNode forKey:url];
    });
}

- (void)removeTreeNodeForURL:(NSURL *)url
{
    dispatch_barrier_async(self.accessQueue, ^{
        [self.dictionary removeObjectForKey:url];
    });
}

@end
