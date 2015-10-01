//
//  GDFileStoreNode.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 15/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GDURLMetadata;

@interface GDFileTreeNode : NSObject

- (instancetype)initWithURL:(NSURL *)url;

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong) id <GDURLMetadata> metadata;
@property (nonatomic, copy) NSArray *directoryContents;

@end
