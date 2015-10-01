//
//  GDFileManagerDownloadOperation_Private.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 18/08/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDFileManagerDownloadOperation.h"

@interface GDFileManagerDownloadOperation ()

@property (nonatomic, readonly, strong) void (^success)(NSURL *localURL, GDURLMetadata *metadata);
@property (nonatomic, readonly, strong) void (^failure)(NSError *error);

- (void)downloadFile;

@end
