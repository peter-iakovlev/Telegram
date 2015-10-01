//
//  GDURLMetadata_Private.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 17/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDURLMetadata.h"
#import "GDURLMetadataInternal.h"

@interface GDURLMetadata () <GDURLMetadata>

- (id)initWithURLMetadata:(id <GDURLMetadata>)metadata clientURL:(NSURL *)url canonicalURL:(NSURL *)canonicalURL;

@end
