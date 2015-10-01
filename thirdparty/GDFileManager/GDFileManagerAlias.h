//
//  GDFileManagerAlias.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 21/08/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDURLMetadata.h"

@class GDFileManager;

@interface GDFileManagerAlias : NSObject <NSCoding>

@property (nonatomic, readonly) NSURL *originalURL;
@property (nonatomic, readonly) NSString *originalFilenamePath;
@property (nonatomic, readonly) GDURLMetadata *originalMetadata;

@end
