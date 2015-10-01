//
//  GDGoogleDriveChange.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 27/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDDictionaryBackedObject.h"

@class GDGoogleDriveMetadata;

@interface GDGoogleDriveChange : GDDictionaryBackedObject

@property (nonatomic, readonly) GDGoogleDriveMetadata *fileMetadata;

@end
