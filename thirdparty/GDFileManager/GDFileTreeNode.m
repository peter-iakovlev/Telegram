//
//  GDFileStoreNode.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 15/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileTreeNode.h"

@implementation GDFileTreeNode

- (id)init
{
    return [self initWithURL:nil];
}

- (id)initWithURL:(NSURL *)url
{
    NSParameterAssert(url);
    
    if ((self = [super init])) {
        _url = url;
    }
    
    return self;
}

@end
