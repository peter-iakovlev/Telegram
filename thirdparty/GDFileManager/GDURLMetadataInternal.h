//
//  GDURLMetadata.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 24/01/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDMetadataCache.h"
#import "GDURLMetadata.h"

@protocol GDURLMetadata <GDURLMetadataProperties>

+ (instancetype)alloc;
- (id)initWithMetadataDictionary:(NSDictionary *)metadataDictionary;

- (NSDictionary *)jsonDictionary;
- (id <GDURLMetadata>)cacheableMetadata;

@end
