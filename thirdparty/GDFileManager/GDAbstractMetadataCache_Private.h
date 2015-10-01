//
//  GDAbstractMetadataCache_Private.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 15/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDAbstractMetadataCache.h"

#import "GDFileTreeNode.h"

@interface GDAbstractMetadataCache ()

- (GDFileTreeNode *)treeNodeForURL:(NSURL *)url;
- (void)setTreeNode:(GDFileTreeNode *)treeNode forURL:(NSURL *)url;
- (void)removeTreeNodeForURL:(NSURL *)url;

@end
